require "test_helper"

class Dashboard::PeopleControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "director lists and filters people" do
    sign_in users(:director)

    get people_url
    assert_response :success
    assert_select "td", text: "GARCÍA PÉREZ ANA"

    get people_url, params: { faculty: "08", since: 2010, situation: "active" }
    assert_response :success
    assert_select "tbody tr", 1
  end

  test "subdirector sees a person and a project" do
    sign_in users(:subdirector)

    get person_url(people(:active_engineer))
    assert_response :success
    assert_select "h1", "GARCÍA PÉREZ ANA"
    assert_match "Monto dudoso", response.body

    get research_project_url(research_projects(:engineering_project))
    assert_response :success
    assert_match "NÚÑEZ ROJAS LUIS", response.body
  end

  test "dtic head is turned away" do
    sign_in users(:dtic_head)

    get people_url
    assert_redirected_to dashboard_index_path

    get person_url(people(:active_engineer))
    assert_redirected_to dashboard_index_path

    get research_project_url(research_projects(:engineering_project))
    assert_redirected_to dashboard_index_path
  end

  test "anonymous visitors must sign in" do
    get people_url
    assert_redirected_to new_user_session_path
  end
end
