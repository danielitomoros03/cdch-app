# == Schema Information
#
# Table name: calls
#
#  id                :bigint           not null, primary key
#  active            :boolean          default(FALSE)
#  end_date          :datetime
#  kind              :integer
#  short_description :string
#  start_date        :datetime
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require "test_helper"

class CallTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
