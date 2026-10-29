require "test_helper"

class Dashboard::PeopleControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "director lists and filters people" do
    sign_in users(:director)

    get people_url
    assert_response :success
    assert_select "td", text: "García Pérez Ana"

    get people_url, params: { faculty: "08", since: 2010, situation: "active" }
    assert_response :success
    assert_select "tbody tr", 1
  end

  test "subdirector sees a person and a project" do
    sign_in users(:subdirector)

    get person_url(people(:active_engineer))
    assert_response :success
    assert_select "h1", "García Pérez Ana"
    assert_match "Monto dudoso", response.body

    get research_project_url(research_projects(:engineering_project))
    assert_response :success
    assert_match "Núñez Rojas Luis", response.body
  end

  test "filters answer a turbo frame request with only the results" do
    sign_in users(:director)

    get people_url, params: { q: "garcia" }, headers: { "Turbo-Frame" => "people_results" }
    assert_response :success
    assert_select "turbo-frame#people_results td", text: "García Pérez Ana"
    assert_select "nav.dashboard-nav", false
  end

  test "dashboard layout marks the section and remembers a collapsed menu" do
    sign_in users(:director)

    get people_url
    assert_select ".dashboard:not(.dashboard--collapsed)"
    assert_select "a.dashboard-nav__link.is-active[href=?]", people_path

    cookies[:sidebar] = "collapsed"
    get person_url(people(:active_engineer))
    assert_select ".dashboard.dashboard--collapsed"
    assert_select "a.dashboard-nav__link.is-active[href=?]", people_path
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
