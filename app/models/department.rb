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
    has_rich_text :description

    ## Validations
    validates :acronym, presence: true, uniqueness: true
end
