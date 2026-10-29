require "test_helper"

class TeacherSpaceTest < ActionDispatch::IntegrationTest
  setup { GeneralSetup.current.update!(teacher_space_enabled: true) }

  test "a teacher enters with id number and hire date and sees only their own record" do
    post teacher_session_url, params: { id_number: "V-90.000.002", hired_on: "1980-01-01" }
    assert_redirected_to teacher_space_url
    assert people(:retired_doctor).reload.space_activated_at

    follow_redirect!
    assert_response :success
    assert_select "h1", "Hola, Núñez Rojas Luis"
    assert_select "td", text: "Coinvestigador"
    assert_no_match(/arbitr/i, response.body)
    assert_no_match "correo-ficticio@example.com", response.body
  end

  test "a wrong hire date gets the same answer as an unknown id number" do
    post teacher_session_url, params: { id_number: "90000002", hired_on: "1981-01-01" }
    assert_response :unprocessable_entity
    wrong_date = css_select(".alert").text

    post teacher_session_url, params: { id_number: "99999999", hired_on: "1981-01-01" }
    assert_response :unprocessable_entity
    assert_equal wrong_date, css_select(".alert").text

    get teacher_space_url
    assert_redirected_to new_teacher_session_url
  end

  test "an id number is locked after repeated failures, even with the right date" do
    TeacherAccessAttempt::MAX_FAILURES.times do
      post teacher_session_url, params: { id_number: "90000002", hired_on: "1999-01-01" }
    end

    post teacher_session_url, params: { id_number: "90000002", hired_on: "1980-01-01" }
    assert_response :unprocessable_entity
    assert_match "demasiados intentos", response.body
  end

  test "people outside the payroll cannot enter" do
    post teacher_session_url, params: { id_number: "90000003", hired_on: "2005-01-01" }
    assert_response :unprocessable_entity
  end

  test "a teacher updates their contact data, kept apart from the legacy contacts" do
    person = people(:active_engineer)
    person.contacts.create!(kind: "email", value: "viejo@example.com", source: "legado_persona")
    post teacher_session_url, params: { id_number: "90000001", hired_on: "2005-01-01" }

    patch teacher_space_url, params: { teacher_profile: { email: "Ana@Example.com ", phone: "0412 000 0000", orcid: "https://orcid.org/0000-0002-1825-009x", research_lines: "Hidráulica" } }
    assert_redirected_to teacher_space_url

    person.reload
    assert_equal "ana@example.com", person.teacher_contact("email")
    assert_equal "0412 000 0000", person.teacher_contact("phone")
    assert_equal "0000-0002-1825-009X", person.orcid
    assert person.contacts.exists?(value: "viejo@example.com"), "the legacy contact stays"

    patch teacher_space_url, params: { teacher_profile: { email: "", phone: "", orcid: "123", research_lines: "" } }
    assert_response :unprocessable_entity
    assert_match "0000-0000-0000-0000", response.body
  end

  test "an idle session expires" do
    post teacher_session_url, params: { id_number: "90000001", hired_on: "2005-01-01" }

    travel 31.minutes do
      get teacher_space_url
      assert_redirected_to new_teacher_session_url
    end
  end

  test "the space can be switched off from the general setup" do
    GeneralSetup.current.update!(teacher_space_enabled: false)

    get new_teacher_session_url
    assert_response :not_found
  end
end
