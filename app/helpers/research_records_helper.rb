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

  def peer_review_outcome_badge(review)
    css = if review.opinion_given then "bg-success"
    elsif review.answered_on then "bg-secondary"
    else "bg-light text-dark border"
    end
    tag.span(review.outcome, class: "badge #{css}")
  end

  def yes_no(value)
    { true => "Sí", false => "No" }.fetch(value, "—")
  end

  # Notas del FoxPro con varias líneas (p. ej. correos y teléfonos del árbitro).
  def multiline(text)
    safe_join(text.to_s.lines.map(&:strip).compact_blank, tag.br)
  end

  def confidential_badge
    tag.span(class: "badge text-bg-warning", title: "Visible solo para la Dirección y la Subdirección") do
      tag.i(class: "fas fa-lock me-1", aria: { hidden: true }) + "Confidencial"
    end
  end

  def flagged_amount_badge(record)
    return unless record.amount_flagged

    tag.span("Monto dudoso", class: "badge bg-warning text-dark", title: "Aprobado más de 10 veces lo solicitado; no se usa en totales")
  end
end
