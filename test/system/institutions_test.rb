require "application_system_test_case"

class InstitutionsTest < ApplicationSystemTestCase
  setup do
    @institution = institutions(:one)
  end

  test "visiting the index" do
    visit institutions_url
    assert_selector "h1", text: "Institutions"
  end

  test "should create institution" do
    visit institutions_url
    click_on "New institution"

    fill_in "Acronym", with: @institution.acronym
    fill_in "Address", with: @institution.address
    fill_in "Business hours", with: @institution.business_hours
    fill_in "Description", with: @institution.description
    fill_in "Director email", with: @institution.director_email
    fill_in "Director name", with: @institution.director_name
    fill_in "Facebook url", with: @institution.facebook_url
    fill_in "Founded year", with: @institution.founded_year
    fill_in "Instagram url", with: @institution.instagram_url
    fill_in "Linkedin url", with: @institution.linkedin_url
    fill_in "Mission", with: @institution.mission
    fill_in "Name", with: @institution.name
    fill_in "Primary email", with: @institution.primary_email
    fill_in "Primary phone", with: @institution.primary_phone
    fill_in "Secondary email", with: @institution.secondary_email
    fill_in "Secondary phone", with: @institution.secondary_phone
    fill_in "Threads url", with: @institution.threads_url
    fill_in "Twitter url", with: @institution.twitter_url
    fill_in "Vission", with: @institution.vission
    click_on "Create Institution"

    assert_text "Institution was successfully created"
    click_on "Back"
  end

  test "should update Institution" do
    visit institution_url(@institution)
    click_on "Edit this institution", match: :first

    fill_in "Acronym", with: @institution.acronym
    fill_in "Address", with: @institution.address
    fill_in "Business hours", with: @institution.business_hours
    fill_in "Description", with: @institution.description
    fill_in "Director email", with: @institution.director_email
    fill_in "Director name", with: @institution.director_name
    fill_in "Facebook url", with: @institution.facebook_url
    fill_in "Founded year", with: @institution.founded_year
    fill_in "Instagram url", with: @institution.instagram_url
    fill_in "Linkedin url", with: @institution.linkedin_url
    fill_in "Mission", with: @institution.mission
    fill_in "Name", with: @institution.name
    fill_in "Primary email", with: @institution.primary_email
    fill_in "Primary phone", with: @institution.primary_phone
    fill_in "Secondary email", with: @institution.secondary_email
    fill_in "Secondary phone", with: @institution.secondary_phone
    fill_in "Threads url", with: @institution.threads_url
    fill_in "Twitter url", with: @institution.twitter_url
    fill_in "Vission", with: @institution.vission
    click_on "Update Institution"

    assert_text "Institution was successfully updated"
    click_on "Back"
  end

  test "should destroy Institution" do
    visit institution_url(@institution)
    click_on "Destroy this institution", match: :first

    assert_text "Institution was successfully destroyed"
  end
end
