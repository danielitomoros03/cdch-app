require "test_helper"

# Formulario público de contacto (POST /solicitudes).
class SolicitudesControllerTest < ActionDispatch::IntegrationTest
  def submission(**overrides)
    { solicitude: { full_name: "Ana Pérez", email: "ana@example.com", phone_number: "04120000000",
                    matter: departments(:dadi).id, message: "Quisiera información sobre las convocatorias.",
                    policies: "1" }.merge(overrides) }
  end

  test "a person sends a request and sees the confirmation next to the form" do
    assert_difference("Solicitude.count") { post solicitudes_url, params: submission }

    assert_redirected_to contacto_path(anchor: "mensaje")
    assert_equal SolicitudesController::SENT, flash[:notice]
  end

  test "sending the same message again the same day does not repeat it" do
    post solicitudes_url, params: submission

    assert_no_difference("Solicitude.count") do
      post solicitudes_url, params: submission(email: "ANA@example.com ", message: "Quisiera  información sobre las convocatorias.")
    end
    assert_equal SolicitudesController::ALREADY_SENT, flash[:notice]
  end

  test "a robot that fills the hidden field is told it worked, but nothing is saved" do
    assert_no_difference("Solicitude.count") { post solicitudes_url, params: submission(website: "http://spam.example") }
    assert_equal SolicitudesController::SENT, flash[:notice]
  end

  test "messages with HTML links are dropped" do
    assert_no_difference("Solicitude.count") do
      post solicitudes_url, params: submission(message: "<b>Offer</b> <a href=https://bit.ly/x>here</a>")
    end
  end

  test "an incomplete request says what to fix" do
    assert_no_difference("Solicitude.count") { post solicitudes_url, params: submission(policies: "0") }
    assert_equal SolicitudesController::INVALID, flash[:alert]

    follow_redirect!
    assert_select "#mensaje .alert-warning", text: /No pudimos enviar/
  end
end
