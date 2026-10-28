# Coinvestigador de una etapa. 183 registros del sistema heredado no tienen etapa
# que les corresponda; se conservan con su código de proyecto.
# == Schema Information
#
# Table name: stage_co_investigators
#
#  id               :bigint           not null, primary key
#  project_code     :string
#  stage_number     :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  person_id        :bigint           not null
#  project_stage_id :bigint
#
# Indexes
#
#  index_stage_co_investigators_on_person_id         (person_id)
#  index_stage_co_investigators_on_project_stage_id  (project_stage_id)
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id)
#  fk_rails_...  (project_stage_id => project_stages.id)
#
class StageCoInvestigator < ApplicationRecord
  belongs_to :project_stage, optional: true
  belongs_to :person
end
