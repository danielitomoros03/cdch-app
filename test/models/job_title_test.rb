# == Schema Information
#
# Table name: job_titles
#
#  id         :bigint           not null, primary key
#  name       :string
#  role       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class JobTitleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
