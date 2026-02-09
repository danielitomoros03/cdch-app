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
require "test_helper"

class AnnouncementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
