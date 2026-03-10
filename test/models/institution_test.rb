# == Schema Information
#
# Table name: institutions
#
#  id                          :bigint           not null, primary key
#  acronym                     :string
#  address                     :string
#  business_hours              :string
#  description                 :text
#  director_name               :string
#  director_primary_email      :string
#  director_secondary_email    :string
#  facebook_url                :string
#  founded_year                :integer
#  instagram_url               :string
#  linkedin_url                :string
#  mission                     :text
#  name                        :string
#  primary_email               :string
#  primary_phone               :string
#  secondary_email             :string
#  secondary_phone             :string
#  subdirector_name            :string
#  subdirector_primary_email   :string
#  subdirector_secondary_email :string
#  threads_url                 :string
#  twitter_url                 :string
#  vission                     :text
#  youtube_url                 :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
require "test_helper"

class InstitutionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
