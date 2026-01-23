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
require "test_helper"

class DirectoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
