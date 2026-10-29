# La historia del docente en el CDCH tal como la ve él mismo: una fila por etapa de
# proyecto, ayuda o beca, sin montos ni observaciones internas. Nunca incluye arbitrajes.
class TeacherHistory
  Entry = Struct.new(:date, :kind, :title, :role, :status)

  def initialize(person)
    @person = person
  end

  def entries
    @entries ||= (led_stages + co_stages + aids + scholarships).sort_by { |entry| entry.date || Date.new(1900) }.reverse
  end

  def counts
    { "Etapas como responsable" => led_stages.size, "Etapas como coinvestigador" => co_stages.size,
      "Ayudas institucionales" => aids.size, "Becas" => scholarships.size }
  end

  private

  def led_stages
    @led_stages ||= @person.led_stages.includes(:legacy_status, research_project: :project_type).map do |stage|
      Entry.new(stage.requested_on, stage_kind(stage), stage.title || stage.research_project.title, "Responsable", stage.legacy_status&.name)
    end
  end

  def co_stages
    @co_stages ||= @person.co_investigations.includes(project_stage: [ :legacy_status, { research_project: :project_type } ]).map do |co|
      stage = co.project_stage
      Entry.new(stage&.requested_on, stage ? stage_kind(stage) : "Proyecto", stage&.title, "Coinvestigador", stage&.legacy_status&.name)
    end
  end

  def aids
    @aids ||= @person.institutional_aids.includes(:legacy_status, :project_type).map do |aid|
      Entry.new(aid.requested_on, aid.project_type&.name || "Ayuda institucional", aid.description, "Solicitante", aid.legacy_status&.name)
    end
  end

  def scholarships
    @scholarships ||= @person.scholarships.map do |scholarship|
      kind = [ "Beca", scholarship.program, scholarship.level ].compact_blank.join(" · ")
      place = [ scholarship.specialty, scholarship.institution, scholarship.country ].compact_blank.join(", ")
      Entry.new(scholarship.starts_on || scholarship.approved_on, kind, place, "Becario", scholarship.status)
    end
  end

  def stage_kind(stage)
    type = stage.research_project.project_type&.name || "Proyecto"
    stage.number ? "#{type} · etapa #{stage.number}" : type
  end
end
