# Cifras de Saber-UCV para el inicio del dashboard (Dirección, Subdirección y DTIC): cuánto hay en
# el repositorio y cuánto de eso está vinculado con docentes de la UCV.
class SaberStats
  TOP_KINDS = 8
  YEARS = 15

  KindRow = Struct.new(:label, :total, :teachers, keyword_init: true)
  YearRow = Struct.new(:year, :total, :teachers, keyword_init: true)

  def any?
    items_total.positive?
  end

  def items_total
    @items_total ||= SaberItem.current.count
  end

  # Ítems vigentes con al menos un docente vinculado.
  def items_with_teachers
    @items_with_teachers ||= linked_items.count
  end

  def teachers_with_publications
    @teachers_with_publications ||= Person.with_saber_publications.count
  end

  def active_with_publications
    @active_with_publications ||= Person.payroll_active.with_saber_publications.count
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
      totals = SaberItem.current.group(:kind).count
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
      totals = SaberItem.current.where(issued_year: range).group(:issued_year).count
      teachers = linked_items.where(issued_year: range).group(:issued_year).count
      range.map { |year| YearRow.new(year: year, total: totals[year].to_i, teachers: teachers[year].to_i) }
    end
  end

  def max_year_total
    by_year.map(&:total).max.to_i
  end

  private

  def linked_items
    SaberItem.current.where(id: SaberAuthorship.accepted.select(:saber_item_id))
  end
end
