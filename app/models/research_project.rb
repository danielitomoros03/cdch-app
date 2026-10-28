# Proyecto de investigación del sistema heredado. Agrupa sus etapas; título y
# responsable pueden cambiar de una etapa a otra.
# == Schema Information
#
# Table name: research_projects
#
#  id                 :bigint           not null, primary key
#  code               :string           not null
#  faculty_code       :string
#  first_requested_on :date
#  last_requested_on  :date
#  legacy_code        :string
#  project_type_code  :string           not null
#  specialty          :string
#  title              :text
#  total_stages       :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  department_id      :bigint           not null
#  lead_person_id     :bigint
#  research_area_id   :bigint
#
# Indexes
#
#  index_research_projects_on_department_id               (department_id)
#  index_research_projects_on_faculty_code                (faculty_code)
#  index_research_projects_on_lead_person_id              (lead_person_id)
#  index_research_projects_on_legacy_code                 (legacy_code)
#  index_research_projects_on_project_type_code           (project_type_code)
#  index_research_projects_on_project_type_code_and_code  (project_type_code,code) UNIQUE
#  index_research_projects_on_research_area_id            (research_area_id)
#
# Foreign Keys
#
#  fk_rails_...  (department_id => departments.id)
#  fk_rails_...  (lead_person_id => people.id)
#  fk_rails_...  (research_area_id => research_areas.id)
#
class ResearchProject < ApplicationRecord
  belongs_to :department
  belongs_to :lead_person, class_name: "Person", optional: true
  belongs_to :research_area, optional: true
  belongs_to :project_type, foreign_key: :project_type_code, primary_key: :code, optional: true
  belongs_to :faculty, foreign_key: :faculty_code, primary_key: :code, optional: true

  has_many :stages, -> { order(:number) }, class_name: "ProjectStage", dependent: :restrict_with_error

  validates :project_type_code, :code, presence: true
  validates :code, uniqueness: { scope: :project_type_code }
end
