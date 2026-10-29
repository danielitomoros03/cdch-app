# Los datos que el docente mantiene desde "Mi espacio": correo, teléfono, ORCID y
# líneas de investigación. Sus contactos se guardan aparte de los del sistema heredado.
class TeacherProfile
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :phone, :string
  attribute :orcid, :string
  attribute :research_lines, :string

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "no parece un correo válido" }, allow_blank: true
  validates :phone, length: { maximum: 40 }
  validates :research_lines, length: { maximum: 2_000 }

  attr_reader :person

  def self.for(person)
    new(person, email: person.teacher_contact("email"), phone: person.teacher_contact("phone"),
                orcid: person.orcid, research_lines: person.research_lines)
  end

  def email=(value)
    super(value.to_s.strip.downcase.presence)
  end

  def phone=(value)
    super(value.to_s.squish.presence)
  end

  def initialize(person, attributes = {})
    @person = person
    super(attributes)
  end

  def save
    person.assign_attributes(orcid: orcid, research_lines: research_lines.presence)
    valid?
    person.errors.each { |error| errors.add(error.attribute, error.message) } unless person.valid?
    return false if errors.any?

    Person.transaction do
      person.save!
      replace_contact("email", email)
      replace_contact("phone", phone)
    end
    true
  end

  private

  def replace_contact(kind, value)
    person.contacts.from_teacher.where(kind: kind).delete_all
    return if value.blank?

    # Si el valor ya estaba en el sistema heredado, pasa a ser del docente.
    contact = person.contacts.find_or_initialize_by(kind: kind, value: value)
    contact.update!(source: PersonContact::TEACHER_SOURCE)
  end
end
