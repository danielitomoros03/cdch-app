# == Schema Information
#
# Table name: stage_extensions
#
#  id               :bigint           not null, primary key
#  granted_on       :date
#  stage_number     :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  project_stage_id :bigint           not null
#
# Indexes
#
#  index_stage_extensions_on_project_stage_id  (project_stage_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_stage_id => project_stages.id)
#
class StageExtension < ApplicationRecord
  belongs_to :project_stage
end
