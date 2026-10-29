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

  test "peer reviews show to the direction on the reviewer card and the project" do
    sign_in users(:director)

    get person_url(people(:retired_doctor))
    assert_select "#pane-reviews td", text: "PI-08-0001"
    assert_select "#pane-reviews .badge", text: "Emitió opinión"

    get research_project_url(research_projects(:engineering_project))
    assert_select "td", text: "Árbitro Externo Ficticio"
    assert_select ".badge", text: "Respondió sin opinión"
    assert_match "NO PUEDE ARBITRAR", response.body
  end

  test "superadmin from DTIC sees the person and the project but not the peer reviews" do
    sign_in users(:superadmin)

    get person_url(people(:retired_doctor))
    assert_response :success
    assert_select "#pane-reviews", false
    assert_select ".stat-tile__label", text: "Arbitrajes", count: 0

    get research_project_url(research_projects(:engineering_project))
    assert_response :success
    assert_no_match "Árbitro Externo Ficticio", response.body
    assert_no_match "NO PUEDE ARBITRAR", response.body
  end

  test "exports the filtered list to a styled spreadsheet" do
    sign_in users(:director)

    get people_url(format: :xlsx, faculty: "09")
    assert_response :success
    assert_equal Mime[:xlsx].to_s, response.media_type
    assert_match(/docentes-cdch-\d{4}-\d{2}-\d{2}\.xlsx/, response.headers["Content-Disposition"])

    sheet = spreadsheet_xml(response.body)
    names = sheet.xpath("//x:row[position() > 3]/x:c[1]//x:t", x: SHEET_NS).map(&:text)
    assert_equal [ "Núñez Rojas Luis", "Soto María" ], names.sort
    assert_equal "Arbitrajes", sheet.xpath("//x:row[3]/x:c[last()]//x:t", x: SHEET_NS).text
    assert_match "facultad:", sheet.xpath("//x:row[2]//x:t", x: SHEET_NS).text
    assert_equal [ "4", "5" ], sheet.xpath("//x:row[position() > 3]/x:c[1]/@s", x: SHEET_NS).map(&:value), "zebra rows"
    assert_equal "A3:L5", sheet.at_xpath("//x:autoFilter", x: SHEET_NS)["ref"]
  end

  test "spreadsheet leaves out peer reviews for superadmin" do
    sign_in users(:superadmin)

    get people_url(format: :xlsx)
    assert_response :success
    headers = spreadsheet_xml(response.body).xpath("//x:row[3]//x:t", x: SHEET_NS).map(&:text)
    assert_not_includes headers, "Arbitrajes"
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

  private

  SHEET_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main".freeze

  def spreadsheet_xml(body)
    require "zip"
    entries = Zip::File.open_buffer(StringIO.new(body)).entries.to_h { |entry| [ entry.name, entry.get_input_stream.read ] }
    assert_equal %w[[Content_Types].xml _rels/.rels xl/_rels/workbook.xml.rels xl/styles.xml xl/workbook.xml xl/worksheets/sheet1.xml], entries.keys.sort
    Nokogiri::XML(entries.fetch("xl/worksheets/sheet1.xml"))
  end
end
