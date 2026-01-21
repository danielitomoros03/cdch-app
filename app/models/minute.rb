# == Schema Information
#
# Table name: minutes
#
#  id         :bigint           not null, primary key
#  day        :date
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Minute < ApplicationRecord
end
