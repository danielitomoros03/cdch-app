require "test_helper"

class TeacherSpace::SaberAuthorshipsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    GeneralSetup.current.update!(teacher_space_enabled: true)
    @item = SaberItem.create!(handle: "10872/1", title: "Hidráulica de canales", issued_year: 2015, item_type: "Article", author_names: [ "García Pérez, Ana" ])
    @authorship = SaberAuthorship.create!(saber_item: @item, person: people(:active_engineer), author_name: "García Pérez, Ana", matched_by: "nombre")
    book = SaberItem.create!(handle: "10872/2", title: "Manual de riego", issued_year: 2020, item_type: "Book")
    SaberAuthorship.create!(saber_item: book, person: people(:active_engineer), matched_by: "correo")
  end

  test "the director sees the publications of a person, filtered by type and year" do
    sign_in users(:director)

    get person_url(people(:active_engineer))
    assert_select "turbo-frame#saber_publications[src=?]", person_saber_publications_path(people(:active_engineer))

    get person_saber_publications_url(people(:active_engineer))
    assert_select "tbody tr", 2
    assert_select "td", text: "Artículo"
    assert_select "#saber_tipo option", text: "Libro (1)"

    get person_saber_publications_url(people(:active_engineer)), params: { tipo: "libro" }
    assert_select "tbody tr", 1
    assert_select "a", text: "Manual de riego"

    get person_saber_publications_url(people(:active_engineer)), params: { anio: "2015" }
    assert_select "a", text: "Hidráulica de canales"

    get people_url, params: { saber: "1" }
    assert_select "tbody tr", 1
  end

  test "a department head without research access cannot open them" do
    sign_in users(:dadi_head)

    get person_saber_publications_url(people(:active_engineer))
    assert_response :redirect
  end

  test "a teacher says a publication is not theirs, then undoes it, keeping the filters" do
    post teacher_session_url, params: { id_number: "90000001", hired_on: "2005-01-01" }

    get saber_authorships_url
    assert_select "a", text: "Hidráulica de canales"

    patch reject_saber_authorship_url(@authorship), params: { tipo: "articulo" }
    assert_redirected_to saber_authorships_url(tipo: "articulo")
    assert @authorship.reload.rejected?
    assert AuditVersion.exists?(event: "saber_authorship_rejected", actor_type: "Person")

    follow_redirect!
    assert_select "summary", text: /una publicación como no tuya/

    patch restore_saber_authorship_url(@authorship)
    assert_not @authorship.reload.rejected?
  end

  test "a teacher cannot touch someone else's publications" do
    other = SaberAuthorship.create!(saber_item: @item, person: people(:retired_doctor), matched_by: "nombre")
    post teacher_session_url, params: { id_number: "90000001", hired_on: "2005-01-01" }

    patch reject_saber_authorship_url(other)
    assert_response :not_found
    assert_not other.reload.rejected?
  end
end
