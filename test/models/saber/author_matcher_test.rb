require "test_helper"

class Saber::AuthorMatcherTest < ActiveSupport::TestCase
  setup do
    @ana = people(:active_engineer)      # GARCÍA PÉREZ ANA
    @luis = people(:retired_doctor)      # NÚÑEZ ROJAS LUIS
    Person.create!(id_number: "90000010", full_name: "GARCÍA ANA")
  end

  def item(handle, authors, emails: [])
    SaberItem.create!(handle: "10872/#{handle}", title: "Ítem #{handle}", author_names: authors, emails: emails)
  end

  test "links only safe name matches and email matches" do
    full = item(1, [ "García Pérez, Ana" ])
    reversed_accents = item(2, [ "Nuñez Rojas, Luis" ])
    too_short = item(3, [ "García, Ana" ])                # one surname + one name: two people fit
    initials = item(4, [ "García Pérez, A." ])
    by_email = item(5, [ "Desconocido, Autor" ], emails: [ "luis@example.com" ])
    @luis.contacts.create!(kind: "email", value: "Luis@Example.com", source: "legado_persona")

    Saber::AuthorMatcher.new.run

    assert_equal [ @ana.id ], full.authorships.pluck(:person_id)
    assert_equal [ @luis.id ], reversed_accents.authorships.pluck(:person_id)
    assert_empty too_short.authorships
    assert_empty initials.authorships
    assert_equal [ [ @luis.id, "correo" ] ], by_email.authorships.pluck(:person_id, :matched_by)
  end

  test "an ambiguous full name is not linked" do
    Person.create!(id_number: "90000011", full_name: "ANA GARCÍA PÉREZ")
    publication = item(6, [ "García Pérez, Ana" ])

    Saber::AuthorMatcher.new.run

    assert_empty publication.authorships
  end

  test "rejected links are never recreated and stale links are removed" do
    publication = item(7, [ "García Pérez, Ana" ])
    Saber::AuthorMatcher.new.run
    publication.authorships.first.update!(rejected_at: Time.current)

    result = Saber::AuthorMatcher.new.run
    assert_equal 0, result.created
    assert_equal 1, publication.authorships.rejected.count

    other = item(8, [ "Núñez Rojas, Luis" ])
    Saber::AuthorMatcher.new.run
    other.update!(author_names: [ "Otro Autor, Alguien" ])
    assert_equal 1, Saber::AuthorMatcher.new.run.removed
    assert_empty other.authorships
  end
end

class SaberItemKindTest < ActiveSupport::TestCase
  test "groups the types Saber writes by hand" do
    assert_equal "articulo", SaberItem.kind_for("Article")
    assert_equal "articulo", SaberItem.kind_for("Artículo Publicado")
    assert_equal "articulo", SaberItem.kind_for("Articule")
    assert_equal "trabajo_grado", SaberItem.kind_for("bachelorThesis")
    assert_equal "tesis_maestria", SaberItem.kind_for("masterThesis")
    assert_equal "capitulo", SaberItem.kind_for("Book chapter")
    assert_equal "curriculo", SaberItem.kind_for("Acosta Johanna - Curriculum Vitae")
    assert_equal "otro", SaberItem.kind_for(nil)
    assert_equal "Informe técnico", SaberItem.kind_label(SaberItem.kind_for("Technical Report"))
  end
end
