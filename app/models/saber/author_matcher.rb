module Saber
  # Atribuye las publicaciones de Saber a personas de cdch-app (SaberAuthorship).
  #
  # Saber guarda a los autores como texto ("Apellidos, Nombres"), escrito a mano y sin
  # identificador. Solo se vincula en dos casos:
  # - por correo: Saber publica en el ítem un correo que cdch-app tiene de una sola persona;
  # - por nombre, solo si la coincidencia es segura: apellidos y nombres completos (al menos
  #   tres palabras en total, sin contar iniciales) que encajan con una única persona.
  # Lo demás (un apellido y un nombre, solo iniciales, varias personas posibles) no se vincula.
  # Medido el 2026-11-03 contra los correos: ~97 % de acierto.
  #
  # Se recalcula entero en cada corrida: crea los vínculos nuevos, quita los que ya no
  # aplican y nunca toca ni recrea los que el docente rechazó.
  class AuthorMatcher
    PARTICLES = %w[DE DEL LA LAS LOS Y E DA DI DO DOS VAN VON DER MC].to_set.freeze
    MIN_WORDS = 3

    Candidate = Struct.new(:id, :all_words, :first_words, :last_words)
    Result = Struct.new(:created, :removed, :kept, keyword_init: true)

    def self.words(text)
      I18n.transliterate(text.to_s).upcase.gsub(/[^A-Z\s]/, " ").split.reject { |word| PARTICLES.include?(word) }
    end

    def run
      load_people
      wanted = {}
      SaberItem.current.select(:id, :author_names, :emails).find_each do |item|
        item.emails.each do |email|
          person_id = @emails[email]
          wanted[[ item.id, person_id ]] ||= [ nil, "correo" ] if person_id
        end
        item.author_names.each do |name|
          person_id = person_for(name)
          wanted[[ item.id, person_id ]] = [ name, wanted.dig([ item.id, person_id ], 1) || "nombre" ] if person_id
        end
      end
      apply(wanted)
    end

    # La persona a la que corresponde con seguridad un nombre de Saber, o nil.
    def person_for(name)
      surnames, given, initials = split(name)
      return if surnames.empty? || given.empty? || surnames.size + given.size < MIN_WORDS

      pool = (surnames + given).map { |word| @index.fetch(word, EMPTY) }.reduce(:&)
      matches = pool.select { |index| fits?(@people[index], surnames, given, initials) }
      @people[matches.first].id if matches.size == 1
    end

    private

    EMPTY = Set.new.freeze

    def load_people
      @people = []
      @index = Hash.new { |hash, key| hash[key] = Set.new }
      Person.pluck(:id, :full_name, :payroll_name, :first_names, :last_names).each do |id, full, payroll, first, last|
        all = Set.new(self.class.words(full) + self.class.words(payroll) + self.class.words(first) + self.class.words(last))
        split_known = last.present?
        @people << Candidate.new(id, all, split_known ? Set.new(self.class.words(first)) : nil, split_known ? Set.new(self.class.words(last)) : nil)
        all.each { |word| @index[word] << (@people.size - 1) }
      end
      @index.default_proc = nil

      by_email = PersonContact.where(kind: "email").pluck(Arel.sql("lower(value)"), :person_id).group_by(&:first)
      @emails = by_email.filter_map { |email, rows| [ email, rows.first.last ] if rows.map(&:last).uniq.size == 1 }.to_h
    end

    # "Pérez Gómez, Juan C." → [["PEREZ", "GOMEZ"], ["JUAN"], ["C"]]
    def split(name)
      return [ [], [], [] ] unless name.include?(",")

      surnames, given = name.split(",", 2)
      complete, initials = [], []
      I18n.transliterate(given).upcase.scan(/[^\s.]+\.?/).each do |piece|
        word = piece.gsub(/[^A-Z]/, "")
        next if word.empty? || PARTICLES.include?(word)

        (word.size == 1 || (piece.end_with?(".") && word.size <= 2) ? initials : complete) << word
      end
      [ self.class.words(surnames), complete, initials ]
    end

    # Respeta el orden apellidos/nombres cuando cdch-app lo conoce; si no, basta con que
    # estén todas las palabras. Una inicial debe corresponder a otro nombre de la persona.
    def fits?(person, surnames, given, initials)
      last_words = person.last_words || person.all_words
      first_words = person.first_words || person.all_words
      return false unless surnames.all? { |word| last_words.include?(word) } && given.all? { |word| first_words.include?(word) }
      return true if initials.empty?

      others = first_words - given
      others -= surnames if person.first_words.nil?
      others.any? { |word| word.start_with?(initials.first) }
    end

    def apply(wanted)
      existing = SaberAuthorship.pluck(:saber_item_id, :person_id, :rejected_at, :id).to_h { |item, person, rejected, id| [ [ item, person ], [ rejected, id ] ] }
      now = Time.current
      rows = wanted.filter_map do |(item_id, person_id), (name, matched_by)|
        next if existing.key?([ item_id, person_id ])

        { saber_item_id: item_id, person_id: person_id, author_name: name, matched_by: matched_by, created_at: now, updated_at: now }
      end
      stale = existing.filter_map { |key, (rejected, id)| id if rejected.nil? && !wanted.key?(key) }

      SaberAuthorship.transaction do
        SaberAuthorship.insert_all(rows) if rows.any?
        SaberAuthorship.where(id: stale).delete_all if stale.any?
      end
      Result.new(created: rows.size, removed: stale.size, kept: existing.size - stale.size)
    end
  end
end
