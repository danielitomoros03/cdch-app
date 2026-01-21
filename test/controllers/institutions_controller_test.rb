require "test_helper"

class InstitutionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @institution = institutions(:one)
  end

  test "should get index" do
    get institutions_url
    assert_response :success
  end

  test "should get new" do
    get new_institution_url
    assert_response :success
  end

  test "should create institution" do
    assert_difference("Institution.count") do
      post institutions_url, params: { institution: { acronym: @institution.acronym, address: @institution.address, business_hours: @institution.business_hours, description: @institution.description, director_email: @institution.director_email, director_name: @institution.director_name, facebook_url: @institution.facebook_url, founded_year: @institution.founded_year, instagram_url: @institution.instagram_url, linkedin_url: @institution.linkedin_url, mission: @institution.mission, name: @institution.name, primary_email: @institution.primary_email, primary_phone: @institution.primary_phone, secondary_email: @institution.secondary_email, secondary_phone: @institution.secondary_phone, threads_url: @institution.threads_url, twitter_url: @institution.twitter_url, vission: @institution.vission } }
    end

    assert_redirected_to institution_url(Institution.last)
  end

  test "should show institution" do
    get institution_url(@institution)
    assert_response :success
  end

  test "should get edit" do
    get edit_institution_url(@institution)
    assert_response :success
  end

  test "should update institution" do
    patch institution_url(@institution), params: { institution: { acronym: @institution.acronym, address: @institution.address, business_hours: @institution.business_hours, description: @institution.description, director_email: @institution.director_email, director_name: @institution.director_name, facebook_url: @institution.facebook_url, founded_year: @institution.founded_year, instagram_url: @institution.instagram_url, linkedin_url: @institution.linkedin_url, mission: @institution.mission, name: @institution.name, primary_email: @institution.primary_email, primary_phone: @institution.primary_phone, secondary_email: @institution.secondary_email, secondary_phone: @institution.secondary_phone, threads_url: @institution.threads_url, twitter_url: @institution.twitter_url, vission: @institution.vission } }
    assert_redirected_to institution_url(@institution)
  end

  test "should destroy institution" do
    assert_difference("Institution.count", -1) do
      delete institution_url(@institution)
    end

    assert_redirected_to institutions_url
  end
end
