require "test_helper"

class AuditLogTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  WINDOWS_EDGE = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 Edg/130.0.0.0".freeze

  def last_entry
    AuditEntry.new(AuditVersion.newest_first.first)
  end

  test "a successful sign-in is logged with where it came from" do
    post user_session_url, params: { user: { email: users(:dadi_head).email, password: "password" } },
                           headers: { "User-Agent" => WINDOWS_EDGE, "REMOTE_ADDR" => "10.0.0.7" }

    version = AuditVersion.newest_first.first
    assert_equal "sign_in", version.event
    assert_equal "10.0.0.7", version.ip
    assert_equal "Red local", version.location
    assert_equal [ "Windows 10 u 11", "Edge 130" ], [ version.os, version.browser ]
    assert_equal "Dadi head Prueba (DADI) entró al panel", "#{last_entry.actor} #{last_entry.sentence}"
  end

  test "failed sign-ins and the lock they cause are sensitive" do
    user = users(:dadi_head)
    Devise.maximum_attempts.times do
      post user_session_url, params: { user: { email: user.email, password: "equivocada" } }
    end

    assert_equal "account_locked", last_entry.event
    assert last_entry.sensitive?
    assert_match "El sistema bloqueó por una hora la cuenta de «Dadi head Prueba»", "#{last_entry.actor} #{last_entry.sentence}"
    assert_equal Devise.maximum_attempts - 1, AuditVersion.where(event: "sign_in_failed", item_id: user.id).count
  end

  test "an unknown email is logged without a subject" do
    post user_session_url, params: { user: { email: "nadie@example.com", password: "x" } }

    assert_equal "Alguien intentó entrar con un correo que no está registrado: nadie@example.com", "#{last_entry.actor} #{last_entry.sentence}"
  end

  test "changing the general setup reads as a before and after" do
    sign_in users(:dtic_head)
    patch general_setup_url, params: { general_setup: { teacher_space_enabled: "1", email_delivery_enabled: "0" } }

    entry = last_entry
    assert_equal "modificó la configuración general", entry.sentence
    assert_equal [ [ "Mi espacio del docente", "apagado", "encendido" ] ], entry.lines.map(&:to_a)
    assert entry.sensitive?
    assert_equal "Dtic head Prueba (DTIC)", entry.actor
  end

  test "an Excel export is logged with its filters and size" do
    sign_in users(:director)
    get people_url(format: :xlsx, situation: "active")

    entry = last_entry
    assert_equal "export", entry.event
    assert_match "exportó a Excel el listado de docentes e investigadores", entry.sentence
    assert_equal "Filtros", entry.lines.first.label
  end

  test "a teacher's edits are one readable line and their failed attempts are kept" do
    GeneralSetup.current.update!(teacher_space_enabled: true)
    post teacher_session_url, params: { id_number: "90000002", hired_on: "1999-01-01" }
    assert_equal "Alguien intentó entrar a «Mi espacio» con la cédula de «Núñez Rojas Luis» y una fecha de ingreso que no coincide",
                 "#{last_entry.actor} #{last_entry.sentence}"

    post teacher_session_url, params: { id_number: "90000002", hired_on: "1980-01-01" }
    patch teacher_space_url, params: { teacher_profile: { email: "nuevo@example.com", phone: "", orcid: "", research_lines: "Malaria" } }

    entry = last_entry
    assert_equal "Núñez Rojas Luis (docente) actualizó sus datos en «Mi espacio»", "#{entry.actor} #{entry.sentence}"
    assert_equal [ "Correo", "(vacío)", "nuevo@example.com" ], entry.lines.first.to_a
    assert_equal 1, AuditVersion.where(event: "teacher_profile_updated").count
  end

  test "the direction and DTIC read the log; other departments cannot" do
    sign_in users(:dtic_head)
    patch general_setup_url, params: { general_setup: { teacher_space_enabled: "1" } }
    get audit_logs_url
    assert_response :success
    assert_select ".audit-item__sentence", /modificó la configuración general/

    sign_in users(:director)
    get audit_logs_url(sensitive: "1")
    assert_response :success
    assert_select ".audit-item--sensitive"

    sign_in users(:dadi_head)
    get audit_logs_url
    assert_redirected_to dashboard_index_path
  end
end
