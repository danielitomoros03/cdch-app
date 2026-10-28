# == Schema Information
#
# Table name: research_areas
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  legacy_id  :integer          not null
#
# Indexes
#
#  index_research_areas_on_legacy_id  (legacy_id) UNIQUE
#
class ResearchArea < ApplicationRecord
  validates :legacy_id, presence: true, uniqueness: true
  validates :name, presence: true
end
