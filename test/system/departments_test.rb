require "application_system_test_case"

class Dashboard::DepartmentsTest < ApplicationSystemTestCase
  setup do
    @dashboard_department = dashboard_departments(:one)
  end

  test "visiting the index" do
    visit dashboard_departments_url
    assert_selector "h1", text: "Departments"
  end

  test "should create department" do
    visit dashboard_departments_url
    click_on "New department"

    fill_in "Acronym", with: @dashboard_department.acronym
    fill_in "Name", with: @dashboard_department.name
    click_on "Create Department"

    assert_text "Department was successfully created"
    click_on "Back"
  end

  test "should update Department" do
    visit dashboard_department_url(@dashboard_department)
    click_on "Edit this department", match: :first

    fill_in "Acronym", with: @dashboard_department.acronym
    fill_in "Name", with: @dashboard_department.name
    click_on "Update Department"

    assert_text "Department was successfully updated"
    click_on "Back"
  end

  test "should destroy Department" do
    visit dashboard_department_url(@dashboard_department)
    click_on "Destroy this department", match: :first

    assert_text "Department was successfully destroyed"
  end
end
