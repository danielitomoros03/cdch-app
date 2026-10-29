# Docente o investigador, identificado por cédula. Reúne la nómina 2026 y la
# historia del sistema FoxPro. Datos de uso interno: solo Dirección y Subdirección.
# == Schema Information
#
# Table name: people
#
#  id                  :bigint           not null, primary key
#  aid_applicant       :boolean          default(FALSE), not null
#  co_investigator     :boolean          default(FALSE), not null
#  first_names         :string
#  full_name           :string           not null
#  id_number           :string           not null
#  in_payroll          :boolean          default(FALSE), not null
#  last_names          :string
#  legacy_category     :string
#  legacy_condition    :string
#  legacy_dedication   :string
#  legacy_faculty_code :string
#  legacy_position     :string
#  nationality         :string
#  payroll_name        :string
#  payroll_status      :string
#  project_lead        :boolean          default(FALSE), not null
#  reviewer            :boolean          default(FALSE), not null
#  scholar             :boolean          default(FALSE), not null
#  sources             :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_people_on_full_name       (full_name)
#  index_people_on_id_number       (id_number) UNIQUE
#  index_people_on_payroll_status  (payroll_status)
#
class Person < ApplicationRecord
  enum :payroll_status, { active: "active", management: "management", retired: "retired" }, prefix: :payroll

  has_many :contacts, class_name: "PersonContact", dependent: :delete_all
  has_many :ucv_appointments, dependent: :delete_all
  has_many :ppi_levels, dependent: :delete_all
  has_many :led_projects, class_name: "ResearchProject", foreign_key: :lead_person_id, inverse_of: :lead_person, dependent: :restrict_with_error
  has_many :led_stages, class_name: "ProjectStage", foreign_key: :lead_person_id, inverse_of: :lead_person, dependent: :restrict_with_error
  has_many :co_investigations, class_name: "StageCoInvestigator", dependent: :restrict_with_error
  has_many :co_investigated_stages, through: :co_investigations, source: :project_stage
  has_many :institutional_aids, foreign_key: :applicant_person_id, inverse_of: :applicant_person, dependent: :restrict_with_error
  has_many :scholarships, dependent: :restrict_with_error

  # Los nombres se guardan en mayúsculas (como la nómina); display_name los presenta en tipo título.
  NAME_FIELDS = %i[full_name first_names last_names payroll_name].freeze
  normalizes(*NAME_FIELDS, with: ->(name) { name.squish.upcase })
  NAME_PARTICLES = %w[de del la las los da di van von].to_set.freeze

  validates :id_number, presence: true, uniqueness: true
  validates :full_name, presence: true

  scope :with_cdch_history, -> { where(project_lead: true).or(where(co_investigator: true)).or(where(reviewer: true)).or(where(aid_applicant: true)).or(where(scholar: true)) }
  scope :outside_payroll, -> { where(in_payroll: false) }
  # Sin importar acentos: "garcia" encuentra "GARCÍA".
  # Sin la extensión unaccent: los nombres se comparan sin tildes con translate().
  UNACCENTED_NAME = "translate(people.full_name, 'ÁÉÍÓÚÜÑáéíóúüñ', 'AEIOUUNaeiouun')".freeze

  scope :search, ->(term) {
    pattern = "%#{sanitize_sql_like(I18n.transliterate(term.to_s.strip))}%"
    where("#{UNACCENTED_NAME} ILIKE :pattern OR people.id_number LIKE :pattern", pattern: pattern)
  }
  # Alfabético sin importar tildes ni mayúsculas; los registros sin nombre (solo cédula) van al final.
  scope :alphabetical, -> { order(Arel.sql("people.full_name ~ '^[0-9]', lower(#{UNACCENTED_NAME})")) }

  SITUATIONS = {
    "active" => "Activo",
    "management" => "Directiva docente",
    "retired" => "Jubilado o pensionado",
    "outside" => "Fuera de nómina 2026"
  }.freeze

  scope :in_situation, ->(situation) { situation == "outside" ? outside_payroll : where(payroll_status: situation) }
  # Facultad de la nómina 2026 o, si no está en nómina, la del sistema heredado.
  scope :in_faculty, ->(code) {
    where(legacy_faculty_code: code).or(where(id: UcvAppointment.where(dependency_code: code).select(:person_id)))
  }
  # Responsable o coinvestigador de alguna etapa solicitada desde ese año.
  scope :with_projects_since, ->(year) {
    stages = ProjectStage.where(requested_on: Date.new(year.to_i)..)
    where(id: stages.select(:lead_person_id))
      .or(where(id: StageCoInvestigator.where(project_stage_id: stages.select(:id)).select(:person_id)))
  }

  # "PORRAS DE PÉREZ MARÍA" → "Porras de Pérez María"; "D'ANGELO" → "D'Angelo".
  def display_name
    word_index = -1
    full_name.downcase.gsub(/[[:alpha:]]+/) do |word|
      word_index += 1
      word_index.positive? && NAME_PARTICLES.include?(word) ? word : word.capitalize
    end
  end

  def situation
    SITUATIONS[payroll_status || "outside"]
  end

  def faculty_code
    current_appointment&.dependency_code || legacy_faculty_code
  end

  def cdch_history?
    project_lead || co_investigator || reviewer || aid_applicant || scholar
  end

  def current_appointment
    ucv_appointments.max_by { |appointment| appointment.hired_on || Date.new(1900) }
  end

  def emails
    contacts.select { |contact| contact.kind == "email" }.map(&:value)
  end
end
