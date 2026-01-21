require "test_helper"

class Dashboard::DepartmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dashboard_department = dashboard_departments(:one)
  end

  test "should get index" do
    get dashboard_departments_url
    assert_response :success
  end

  test "should get new" do
    get new_dashboard_department_url
    assert_response :success
  end

  test "should create dashboard_department" do
    assert_difference("Dashboard::Department.count") do
      post dashboard_departments_url, params: { dashboard_department: { acronym: @dashboard_department.acronym, name: @dashboard_department.name } }
    end

    assert_redirected_to dashboard_department_url(Dashboard::Department.last)
  end

  test "should show dashboard_department" do
    get dashboard_department_url(@dashboard_department)
    assert_response :success
  end

  test "should get edit" do
    get edit_dashboard_department_url(@dashboard_department)
    assert_response :success
  end

  test "should update dashboard_department" do
    patch dashboard_department_url(@dashboard_department), params: { dashboard_department: { acronym: @dashboard_department.acronym, name: @dashboard_department.name } }
    assert_redirected_to dashboard_department_url(@dashboard_department)
  end

  test "should destroy dashboard_department" do
    assert_difference("Dashboard::Department.count", -1) do
      delete dashboard_department_url(@dashboard_department)
    end

    assert_redirected_to dashboard_departments_url
  end
end
