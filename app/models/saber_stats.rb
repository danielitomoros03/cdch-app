# Cifras de Saber-UCV para el inicio del dashboard (Dirección, Subdirección y DTIC): cuánto hay en
# el repositorio y cuánto de eso está vinculado con docentes de la UCV.
# Sin tesis ni trabajos de grado: sus autores son estudiantes y no se pueden vincular. Se informan
# aparte, porque algunas son de quienes luego fueron docentes.
class SaberStats
  TOP_KINDS = 8
  YEARS = 15

  KindRow = Struct.new(:label, :total, :teachers, keyword_init: true)
  YearRow = Struct.new(:year, :total, :teachers, keyword_init: true)

  def any?
    items_total.positive?
  end

  def items_total
    @items_total ||= items.count
  end

  # Ítems vigentes con al menos un docente vinculado.
  def items_with_teachers
    @items_with_teachers ||= linked_items.count
  end

  def teachers_with_publications
    @teachers_with_publications ||= teachers.count
  end

  def active_with_publications
    @active_with_publications ||= teachers.payroll_active.count
  end

  def active_total
    @active_total ||= Person.payroll_active.count
  end

  def active_share
    return 0 if active_total.zero?

    (100.0 * active_with_publications / active_total).round
  end

  # Los tipos más frecuentes; el resto (incluido "otro") va en una sola fila.
  def by_kind
    @by_kind ||= begin
      totals = items.group(:kind).count
      teachers = linked_items.group(:kind).count
      named, rest = totals.except("otro").sort_by { |_kind, count| -count }.partition.with_index { |_, index| index < TOP_KINDS }
      rows = named.map { |kind, count| KindRow.new(label: SaberItem.kind_label(kind), total: count, teachers: teachers[kind].to_i) }
      rest_kinds = rest.map(&:first) + [ "otro" ]
      rest_total = rest_kinds.sum { |kind| totals[kind].to_i }
      rows << KindRow.new(label: "Otros tipos o sin tipo", total: rest_total, teachers: rest_kinds.sum { |kind| teachers[kind].to_i }) if rest_total.positive?
      rows
    end
  end

  # Últimos años por año de publicación (dc.date.issued). En algunos ítems Saber registra ahí el
  # año de carga, así que es una aproximación.
  def by_year
    @by_year ||= begin
      last = Date.current.year
      range = (last - YEARS + 1)..last
      totals = items.where(issued_year: range).group(:issued_year).count
      teachers = linked_items.where(issued_year: range).group(:issued_year).count
      range.map { |year| YearRow.new(year: year, total: totals[year].to_i, teachers: teachers[year].to_i) }
    end
  end

  # Lo que queda fuera de las demás cifras.
  def theses_total
    @theses_total ||= SaberItem.current.theses.count
  end

  def theses_with_teachers
    @theses_with_teachers ||= SaberItem.current.theses.where(id: SaberAuthorship.accepted.select(:saber_item_id)).count
  end

  def max_year_total
    by_year.map(&:total).max.to_i
  end

  private

  def items
    SaberItem.current.without_theses
  end

  def linked_items
    items.where(id: SaberAuthorship.accepted.select(:saber_item_id))
  end

  def teachers
    Person.where(id: SaberAuthorship.accepted.where(saber_item_id: items.select(:id)).select(:person_id))
  end
end
