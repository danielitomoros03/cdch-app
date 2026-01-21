require "application_system_test_case"

class SolicitudesTest < ApplicationSystemTestCase
  setup do
    @solicitude = solicitudes(:one)
  end

  test "visiting the index" do
    visit solicitudes_url
    assert_selector "h1", text: "Solicitudes"
  end

  test "should create solicitude" do
    visit solicitudes_url
    click_on "New solicitude"

    fill_in "Lastname", with: @solicitude.lastname
    fill_in "Matter", with: @solicitude.matter
    fill_in "Message", with: @solicitude.message
    fill_in "Name", with: @solicitude.name
    fill_in "Phone number", with: @solicitude.phone_number
    check "Policies" if @solicitude.policies
    click_on "Create Solicitude"

    assert_text "Solicitude was successfully created"
    click_on "Back"
  end

  test "should update Solicitude" do
    visit solicitude_url(@solicitude)
    click_on "Edit this solicitude", match: :first

    fill_in "Lastname", with: @solicitude.lastname
    fill_in "Matter", with: @solicitude.matter
    fill_in "Message", with: @solicitude.message
    fill_in "Name", with: @solicitude.name
    fill_in "Phone number", with: @solicitude.phone_number
    check "Policies" if @solicitude.policies
    click_on "Update Solicitude"

    assert_text "Solicitude was successfully updated"
    click_on "Back"
  end

  test "should destroy Solicitude" do
    visit solicitude_url(@solicitude)
    click_on "Destroy this solicitude", match: :first

    assert_text "Solicitude was successfully destroyed"
  end
end
