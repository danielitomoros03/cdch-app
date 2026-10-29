require "test_helper"

class PersonTest < ActiveSupport::TestCase
  test "search ignores accents and case" do
    assert_includes Person.search("garcia"), people(:active_engineer)
    assert_includes Person.search("nunez"), people(:retired_doctor)
    assert_includes Person.search("90000003"), people(:former_researcher)
  end

  test "situation filter includes people outside the payroll" do
    assert_equal [ people(:former_researcher) ], Person.in_situation("outside").to_a
    assert_equal [ people(:retired_doctor) ], Person.in_situation("retired").to_a
  end

  test "faculty comes from the payroll or the legacy system" do
    assert_equal [ people(:active_engineer) ], Person.in_faculty("08").to_a
    assert_equal [ people(:former_researcher), people(:retired_doctor) ].sort, Person.in_faculty("09").to_a.sort
  end

  test "projects since a year count leads and co-investigators" do
    assert_equal [ people(:active_engineer), people(:retired_doctor) ].sort, Person.with_projects_since(2010).to_a.sort
    assert_empty Person.with_projects_since(2015)
  end

  test "cdch history" do
    assert_not_includes Person.with_cdch_history, people(:no_history)
    assert_includes Person.with_cdch_history, people(:retired_doctor)
  end

  test "flagged amounts stay out of reliable totals" do
    assert_equal [ project_stages(:first_stage) ], ProjectStage.reliable_amounts.to_a
  end
  test "alphabetical ignores accents and case and leaves nameless records last" do
    Person.create!(id_number: "99000001", full_name: "99000001")
    Person.create!(id_number: "99000002", full_name: "Álvarez Rosa")

    names = Person.alphabetical.pluck(:full_name)
    assert_equal [ "ÁLVAREZ ROSA", "GARCÍA PÉREZ ANA", "LÓPEZ JUAN", "NÚÑEZ ROJAS LUIS", "SOTO MARÍA", "99000001" ], names
  end

  test "names are stored in uppercase" do
    person = Person.create!(id_number: "99000003", full_name: "  Müller  de Ñáñez ", first_names: "aixa")
    assert_equal "MÜLLER DE ÑÁÑEZ", person.full_name
    assert_equal "AIXA", person.first_names
  end

  test "display name is title case with lowercase particles" do
    assert_equal "Porras de Pérez María", Person.new(full_name: "PORRAS DE PÉREZ MARÍA").display_name
    assert_equal "De Abreu Ana", Person.new(full_name: "DE ABREU ANA").display_name
    assert_equal "D'Angelo Luis E.", Person.new(full_name: "D'ANGELO LUIS E.").display_name
  end
end
