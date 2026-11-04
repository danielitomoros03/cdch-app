require "test_helper"

class Saber::HarvesterTest < ActiveSupport::TestCase
  SETS = <<~XML.freeze
    <OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"><ListSets>
      <set><setSpec>col_10872_9</setSpec><setName>Tesis de Ingeniería</setName></set>
    </ListSets></OAI-PMH>
  XML

  def record(handle, title: nil, deleted: false)
    header = %(<header#{' status="deleted"' if deleted}><identifier>oai:saber.ucv.ve:10872/#{handle}</identifier><datestamp>2026-07-01T10:00:00Z</datestamp><setSpec>col_10872_9</setSpec></header>)
    return "<record>#{header}</record>" if deleted

    <<~XML
      <record>#{header}<metadata><dim:dim xmlns:dim="http://www.dspace.org/xmlns/dspace/dim">
        <dim:field mdschema="dc" element="title">#{title}</dim:field>
        <dim:field mdschema="dc" element="contributor" qualifier="author">García Pérez, Ana</dim:field>
        <dim:field mdschema="dc" element="date" qualifier="issued">2013-05-13</dim:field>
        <dim:field mdschema="dc" element="type">Thesis</dim:field>
        <dim:field mdschema="dc" element="identifier" qualifier="other">DOI: 10.5220/0004377706860689</dim:field>
        <dim:field mdschema="dc" element="data" qualifier="correo">Ana@Example.com</dim:field>
      </dim:dim></metadata></record>
    XML
  end

  def page(records, token: nil)
    %(<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"><ListRecords>#{records.join}<resumptionToken>#{token}</resumptionToken></ListRecords></OAI-PMH>)
  end

  test "saves records across pages and reads the DSpace fields" do
    pages = { nil => page([ record(1, title: "Primera") ], token: "abc"), "abc" => page([ record(2, title: "Segunda") ]) }
    http = ->(params) { params[:verb] == "ListSets" ? SETS : pages.fetch(params[:resumptionToken]) }

    result = Saber::Harvester.new(pause: 0, http: http).run(full: true)

    assert_equal 2, result.pages
    item = SaberItem.find_by!(handle: "10872/1")
    assert_equal [ "Primera", "Thesis", 2013, "10.5220/0004377706860689" ], [ item.title, item.item_type, item.issued_year, item.doi ]
    assert_equal [ "García Pérez, Ana" ], item.author_names
    assert_equal [ "ana@example.com" ], item.emails
    assert_equal "Tesis de Ingeniería", SaberCollection.find_by!(spec: "col_10872_9").name
  end

  test "a full harvest marks what Saber no longer returns as deleted" do
    gone = SaberItem.create!(handle: "10872/99", title: "Ya no está")
    http = ->(params) { params[:verb] == "ListSets" ? SETS : page([ record(1, title: "Sigue"), record(2, deleted: true) ]) }

    result = Saber::Harvester.new(pause: 0, http: http).run(full: true)

    assert gone.reload.deleted
    assert SaberItem.find_by!(handle: "10872/2").deleted
    assert_equal 1, result.deleted
  end

  test "an incremental harvest asks only for what changed since the last datestamp" do
    SaberItem.create!(handle: "10872/1", datestamp: Time.utc(2026, 7, 7, 20))
    asked = nil
    http = ->(params) { params[:verb] == "ListSets" ? SETS : (asked = params; %(<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"><error code="noRecordsMatch"/></OAI-PMH>)) }

    Saber::Harvester.new(pause: 0, http: http).run

    assert_equal "2026-07-06", asked[:from]
  end
end
