require "test_helper"

class SaberStatsTest < ActiveSupport::TestCase
  setup do
    @person = Person.create!(full_name: "PRUEBA PANEL, DOCENTE", id_number: "V-99999901")
    @article = SaberItem.create!(handle: "10872/test-articulo", item_type: "Article", title: "Artículo")
    @thesis = SaberItem.create!(handle: "10872/test-tesis", item_type: "Thesis", title: "Tesis")
  end

  test "las tesis no entran en las cifras y se cuentan aparte" do
    SaberAuthorship.create!(saber_item: @thesis, person: @person, matched_by: "nombre")
    stats = SaberStats.new

    assert_equal SaberItem.current.count - SaberItem.current.theses.count, stats.items_total
    assert_not_includes stats.by_kind.map(&:label), "Tesis"
    assert_equal 0, stats.items_with_teachers
    assert_equal 0, stats.teachers_with_publications
    assert_equal 1, stats.theses_with_teachers
  end

  test "un docente con un artículo sí cuenta" do
    SaberAuthorship.create!(saber_item: @article, person: @person, matched_by: "nombre")
    stats = SaberStats.new

    assert_equal 1, stats.items_with_teachers
    assert_equal 1, stats.teachers_with_publications
  end
end
