# Las publicaciones de Saber de una persona, filtradas por tipo y año y paginadas, con
# cuántas hay de cada tipo y de cada año para los selectores. La usan la ficha del
# docente (panel) y "Mi espacio".
class SaberPublicationList
  PER_PAGE = 20

  attr_reader :kind, :year

  def initialize(authorships, kind: nil, year: nil, page: nil)
    @base = authorships.joins(:saber_item).merge(SaberItem.current)
    @kind = kind.presence if SaberItem::KINDS.key?(kind)
    @year = year.to_i if year.to_s.match?(/\A\d{4}\z/)
    @year = :none if year == "sin"
    @page = page
  end

  def authorships
    @authorships ||= filtered.includes(:saber_item).newest_first.paginate(page: @page, per_page: PER_PAGE)
  end

  def total
    @base.count
  end

  # [[etiqueta con cantidad, clave]] de los tipos presentes, del más frecuente al menos.
  def kind_options
    by_year(@base).group("saber_items.kind").count.sort_by { |kind, count| [ -count, kind ] }
                  .map { |kind, count| [ "#{SaberItem.kind_label(kind)} (#{count})", kind ] }
  end

  def year_options
    by_kind(@base).group("saber_items.issued_year").count.sort_by { |year, _| -(year || 0) }
                  .map { |year, count| year ? [ "#{year} (#{count})", year ] : [ "Sin año (#{count})", "sin" ] }
  end

  def filtered?
    kind || year
  end

  def params
    { tipo: kind, anio: (year == :none ? "sin" : year) }.compact
  end

  private

  def filtered
    by_kind(by_year(@base))
  end

  def by_kind(scope)
    kind ? scope.where(saber_items: { kind: kind }) : scope
  end

  def by_year(scope)
    return scope unless year

    scope.where(saber_items: { issued_year: year == :none ? nil : year })
  end
end
