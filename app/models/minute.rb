# == Schema Information
#
# Table name: minutes
#
#  id          :bigint           not null, primary key
#  day         :date
#  description :text
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Minute < ApplicationRecord
    ## Rich text
    has_rich_text :content
    has_one_attached :attachment_minute

    ## Validations
    validates :day, presence: true
    validates :title, presence: true
    validates :content, presence: true
    validates :attachment_minute, presence: true
end
