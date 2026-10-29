# Listado filtrado de docentes en Excel. Recorre las personas en tandas, en el mismo
# orden alfabético de la pantalla, y escribe cada tanda antes de cargar la siguiente.
class PeopleExport
  BATCH = 500

  def initialize(people, faculties:, filters:, reviews:)
    @people = people
    @faculty_names = faculties.to_h { |faculty| [ faculty.code, faculty.name ] }
    @filters = filters
    @reviews = reviews
  end

  def filename
    "docentes-cdch-#{Date.current.iso8601}.xlsx"
  end

  def write(zip)
    Cdch::XlsxWriter.new(zip, title: "Docentes e investigadores · CDCH-UCV", subtitle: subtitle, columns: columns, sheet_name: "Docentes").write do |sheet|
      @people.pluck(:id).each_slice(BATCH) { |ids| write_batch(sheet, ids) }
    end
  end

  private

  def columns
    list = [
      { header: "Nombre", width: 38 }, { header: "Cédula", width: 13 }, { header: "Situación", width: 20 },
      { header: "Facultad o dependencia", width: 34 }, { header: "Categoría", width: 26 }, { header: "Dedicación", width: 22 },
      { header: "Ingreso UCV", width: 12 },
      { header: "Etapas como responsable", width: 13 }, { header: "Etapas como coinvestigador", width: 13 },
      { header: "Ayudas institucionales", width: 12 }, { header: "Becas", width: 9 }
    ]
    list << { header: "Arbitrajes", width: 11 } if @reviews
    list
  end

  def subtitle
    applied = []
    applied << "con historia en el CDCH" if @filters[:history] == "1"
    applied << "nombre o cédula: #{@filters[:q]}" if @filters[:q].present?
    applied << "situación: #{Person::SITUATIONS[@filters[:situation]]}" if Person::SITUATIONS.key?(@filters[:situation])
    applied << "facultad: #{@faculty_names.fetch(@filters[:faculty], @filters[:faculty])}" if @filters[:faculty].present?
    applied << "proyectos desde #{@filters[:since]}" if @filters[:since].present?
    filters = applied.any? ? "Filtros: #{applied.join('; ')}" : "Sin filtros"
    "#{filters} · Generado el #{I18n.l(Time.current, format: '%d/%m/%Y %H:%M')} · Uso interno y confidencial"
  end

  def write_batch(sheet, ids)
    people = Person.where(id: ids).index_by(&:id)
    appointments = UcvAppointment.where(person_id: ids).group_by(&:person_id)
    led = ProjectStage.where(lead_person_id: ids).group(:lead_person_id).count
    co = StageCoInvestigator.where(person_id: ids).group(:person_id).count
    aids = InstitutionalAid.where(applicant_person_id: ids).group(:applicant_person_id).count
    scholarships = Scholarship.where(person_id: ids).group(:person_id).count
    reviews = @reviews ? PeerReview.where(reviewer_person_id: ids).group(:reviewer_person_id).count : {}

    ids.each do |id|
      person = people.fetch(id)
      appointment = appointments[id]&.max_by { |a| a.hired_on || Date.new(1900) }
      faculty_code = appointment&.dependency_code || person.legacy_faculty_code
      row = [
        person.display_name, [ person.nationality, person.id_number ].compact.join("-"), person.situation,
        faculty_code.present? ? @faculty_names.fetch(faculty_code, faculty_code) : nil,
        appointment&.category || person.legacy_category, appointment&.dedication || person.legacy_dedication,
        appointment&.hired_on,
        led.fetch(id, 0), co.fetch(id, 0), aids.fetch(id, 0), scholarships.fetch(id, 0)
      ]
      row << reviews.fetch(id, 0) if @reviews
      sheet << row
    end
  end
end
