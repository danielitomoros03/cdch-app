# == Schema Information
#
# Table name: funding_sources
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_funding_sources_on_code  (code) UNIQUE
#
class FundingSource < ApplicationRecord
  validates :code, presence: true, uniqueness: true
end
