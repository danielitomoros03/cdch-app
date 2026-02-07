# == Schema Information
#
# Table name: publications
#
#  id               :bigint           not null, primary key
#  author_name      :string
#  date_publication :date
#  description      :text
#  kind             :integer          default("Otro")
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require "test_helper"

class PublicationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
