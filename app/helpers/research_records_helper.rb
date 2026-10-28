module ResearchRecordsHelper
  # Monto en su moneda de época; nunca se convierte ni se suma entre monedas.
  def legacy_amount(value, currency)
    return "—" if value.nil?

    tag.span("#{number_with_precision(value, precision: 2, delimiter: ".", separator: ",")} #{currency || "(sin moneda)"}", class: "text-nowrap")
  end

  def legacy_date(date)
    date ? l(date) : "—"
  end

  def faculty_label(code, names)
    return "—" if code.blank?

    names[code] || code
  end

  def situation_badge(person)
    css = { "active" => "bg-success", "management" => "bg-primary", "retired" => "bg-secondary" }.fetch(person.payroll_status, "bg-light text-dark border")
    tag.span(person.situation, class: "badge #{css}")
  end

  def flagged_amount_badge(record)
    return unless record.amount_flagged

    tag.span("Monto dudoso", class: "badge bg-warning text-dark", title: "Aprobado más de 10 veces lo solicitado; no se usa en totales")
  end
end
