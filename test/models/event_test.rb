# == Schema Information
#
# Table name: events
#
#  id          :bigint           not null, primary key
#  active      :boolean
#  day         :date
#  description :text
#  end_time    :time
#  kind        :integer
#  location    :string
#  show_in     :boolean
#  start_time  :time
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "test_helper"

class EventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
