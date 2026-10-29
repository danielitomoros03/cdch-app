require "test_helper"

class Dashboard::GeneralSetupsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  test "dtic switches features on and off" do
    sign_in users(:dtic_head)

    get general_setup_url
    assert_response :success
    assert_select "input[type=submit][value=Guardar]"

    patch general_setup_url, params: { general_setup: { teacher_space_enabled: "1", email_delivery_enabled: "0" } }
    assert_redirected_to general_setup_url
    assert GeneralSetup.teacher_space?
    assert_not GeneralSetup.email_delivery?
    assert_equal users(:dtic_head), GeneralSetup.current.updated_by
  end

  test "the direction can look but not change it" do
    sign_in users(:director)

    get general_setup_url
    assert_response :success
    assert_select "input[type=submit][value=Guardar]", false

    patch general_setup_url, params: { general_setup: { teacher_space_enabled: "1" } }
    assert_not GeneralSetup.teacher_space?
  end

  test "other departments cannot see it" do
    sign_in users(:dadi_head)

    get general_setup_url
    assert_redirected_to dashboard_index_path
  end

  test "no email leaves while delivery is off, except the explicit test message" do
    assert_no_emails { SystemMailer.test_message("alguien@example.com").deliver_now }

    GeneralSetup.current.update!(email_delivery_enabled: true)
    assert_emails(1) { SystemMailer.test_message("alguien@example.com").deliver_now }

    GeneralSetup.current.update!(email_delivery_enabled: false)
    sign_in users(:dtic_head)
    assert_emails(1) { post test_email_general_setup_url }
    assert_redirected_to general_setup_url
  end
end
