# == Schema Information
#
# Table name: solicitudes
#
#  id           :bigint           not null, primary key
#  email        :string
#  full_name    :string
#  matter       :integer
#  message      :text
#  phone_number :string
#  policies     :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require "test_helper"

class SolicitudeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
