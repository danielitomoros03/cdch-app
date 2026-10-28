# == Schema Information
#
# Table name: faculties
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_faculties_on_code  (code) UNIQUE
#
class Faculty < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
