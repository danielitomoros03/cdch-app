# Etapa de un proyecto: es la unidad que se solicita, aprueba y financia.
# Los montos van en la moneda de su época (VEB, VEF, VES, VED) y no se suman entre sí.
# == Schema Information
#
# Table name: project_stages
#
#  id                         :bigint           not null, primary key
#  amount_approved            :decimal(20, 2)
#  amount_equipment           :decimal(20, 2)
#  amount_flagged             :boolean          default(FALSE), not null
#  amount_other               :decimal(20, 2)
#  amount_personnel           :decimal(20, 2)
#  amount_requested           :decimal(20, 2)
#  amount_services            :decimal(20, 2)
#  amount_supplies            :decimal(20, 2)
#  amount_travel              :decimal(20, 2)
#  approved_on                :date
#  area_text                  :string
#  code                       :string
#  cofinanced                 :boolean
#  contract                   :string
#  currency                   :string
#  duration_months            :integer
#  extension_code             :integer
#  extension_on               :date
#  faculty_code               :string
#  final_report_approved_on   :date
#  final_report_ok            :boolean
#  funding_source_code        :string
#  legacy_code                :string
#  merge_note                 :string
#  notes                      :text
#  number                     :integer
#  partial_report_approved_on :date
#  partial_report_ok          :boolean
#  requested_on               :date
#  serial                     :string
#  signed_on                  :date
#  source                     :string
#  specialty                  :string
#  stage_variation            :decimal(20, 2)
#  title                      :text
#  total_stages               :integer
#  work_approved_on           :date
#  work_journal               :text
#  work_title                 :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  lead_person_id             :bigint
#  legacy_id                  :integer          not null
#  legacy_status_id           :bigint
#  research_area_id           :bigint
#  research_project_id        :bigint           not null
#
# Indexes
#
#  index_project_stages_on_lead_person_id       (lead_person_id)
#  index_project_stages_on_legacy_id            (legacy_id) UNIQUE
#  index_project_stages_on_legacy_status_id     (legacy_status_id)
#  index_project_stages_on_requested_on         (requested_on)
#  index_project_stages_on_research_area_id     (research_area_id)
#  index_project_stages_on_research_project_id  (research_project_id)
#
# Foreign Keys
#
#  fk_rails_...  (lead_person_id => people.id)
#  fk_rails_...  (legacy_status_id => legacy_statuses.id)
#  fk_rails_...  (research_area_id => research_areas.id)
#  fk_rails_...  (research_project_id => research_projects.id)
#
class ProjectStage < ApplicationRecord
  include LegacyAmounts

  belongs_to :research_project
  belongs_to :lead_person, class_name: "Person", optional: true
  belongs_to :legacy_status, optional: true
  belongs_to :research_area, optional: true
  belongs_to :funding_source, foreign_key: :funding_source_code, primary_key: :code, optional: true

  has_many :co_investigators, class_name: "StageCoInvestigator", dependent: :restrict_with_error
  has_many :co_investigator_people, through: :co_investigators, source: :person
  has_many :publications, class_name: "StagePublication", dependent: :restrict_with_error
  has_many :extensions, class_name: "StageExtension", dependent: :restrict_with_error
end
