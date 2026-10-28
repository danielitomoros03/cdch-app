# == Schema Information
#
# Table name: stage_publications
#
#  id               :bigint           not null, primary key
#  evaluated_on     :date
#  legacy_code      :string
#  stage_number     :integer
#  title            :text
#  venue            :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  project_stage_id :bigint
#
# Indexes
#
#  index_stage_publications_on_project_stage_id  (project_stage_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_stage_id => project_stages.id)
#
class StagePublication < ApplicationRecord
  belongs_to :project_stage, optional: true
end
