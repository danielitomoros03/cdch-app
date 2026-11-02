module AuditLogsHelper
  def audit_day_label(day)
    return "Hoy" if day == Date.current
    return "Ayer" if day == Date.yesterday

    l(day, format: "%A %-d de %B de %Y").capitalize
  end
end
