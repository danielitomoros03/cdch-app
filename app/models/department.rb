# == Schema Information
#
# Table name: departments
#
#  id         :bigint           not null, primary key
#  acronym    :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Department < ApplicationRecord
    has_rich_text :description # Rich text association
    has_one_attached :logoDepartment # Active Storage association for logotype

    ## Validations
    validates :acronym, presence: true, uniqueness: true
    validates :name, presence: true, uniqueness: true
    validates :description, presence: true
    validates :logoDepartment, presence: true
end
