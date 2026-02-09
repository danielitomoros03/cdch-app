# == Schema Information
#
# Table name: announcements
#
#  id         :bigint           not null, primary key
#  content    :text
#  is_active  :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Announcement < ApplicationRecord
end
