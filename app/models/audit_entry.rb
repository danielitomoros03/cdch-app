# Una línea de la bitácora contada en castellano: quién, qué hizo y sobre qué, qué
# cambió (antes → después) y desde dónde. La redacción está en es.yml, bajo `audit`.
class AuditEntry
  CHANGE_EVENTS = %w[create update destroy].freeze
  HIDDEN_FIELDS = %w[id created_at updated_at].freeze
  LONG_TEXT = 120

  CATEGORIES = {
    "accesos" => { label: "Entradas y bloqueos", icon: "fa-key",
                   events: %w[sign_in sign_in_remembered sign_in_failed account_locked account_unlocked password_changed
                              teacher_sign_in teacher_sign_in_failed teacher_locked] },
    "usuarios" => { label: "Usuarios y permisos", icon: "fa-user-shield", types: %w[User JobTitle], events: %w[permissions_changed] },
    "configuracion" => { label: "Configuración", icon: "fa-sliders-h", types: %w[GeneralSetup Department Institution], events: %w[test_email_sent] },
    "exportaciones" => { label: "Exportaciones", icon: "fa-file-excel", events: %w[export] },
    "docentes" => { label: "Mi espacio del docente", icon: "fa-chalkboard-teacher", events: %w[teacher_profile_updated saber_authorship_rejected saber_authorship_restored] },
    "contenido" => { label: "Contenido del sitio", icon: "fa-newspaper",
                     types: %w[Call Event Publication Minute Announcement Solicitude InstitutionLeadership] }
  }.freeze

  # Quien falla al entrar no es nadie todavía; los bloqueos los pone el sistema.
  ANONYMOUS_EVENTS = %w[sign_in_failed teacher_sign_in_failed].freeze
  SYSTEM_EVENTS = %w[account_locked teacher_locked].freeze

  # Valor antes y después de un campo. Sin `after`, `before` es el único valor a mostrar.
  Line = Struct.new(:label, :before, :after)

  def self.in_category(scope, key)
    rule = CATEGORIES[key]
    return scope unless rule

    [
      (scope.where(event: rule[:events]) if rule[:events]),
      (scope.where(item_type: rule[:types], event: CHANGE_EVENTS) if rule[:types])
    ].compact.reduce(:or)
  end

  attr_reader :version

  delegate :created_at, :sensitive?, :event, to: :version

  def initialize(version)
    @version = version
  end

  def actor
    return version.actor_label if version.actor_label.present?
    return t("anonymous") if ANONYMOUS_EVENTS.include?(event)
    return t("system") if SYSTEM_EVENTS.include?(event) || version.ip.blank?

    t("visitor")
  end

  def sentence
    CHANGE_EVENTS.include?(event) ? t("changes.#{event}", subject: subject) : event_sentence
  end

  def lines
    return change_lines if event == "update"

    case event
    when "permissions_changed" then permission_lines
    when "teacher_profile_updated" then teacher_lines
    when "export" then export_lines
    else []
    end
  end

  # Desde dónde: ubicación aproximada, IP, sistema operativo y navegador.
  def context
    [ version.location, (t("ip", ip: version.ip) if version.ip.present?), version.os, version.browser ].compact_blank
  end

  def icon
    return "fa-trash-alt" if event == "destroy"

    CATEGORIES.dig(category, :icon) || "fa-circle"
  end

  def category
    CATEGORIES.find do |_key, rule|
      Array(rule[:events]).include?(event) || (Array(rule[:types]).include?(version.item_type) && CHANGE_EVENTS.include?(event))
    end&.first
  end

  private

  def details
    version.details || {}
  end

  def label
    version.item_label.presence || "n.º #{version.item_id}"
  end

  def subject
    key = version.item_type.to_s.underscore
    model = item_class&.model_name&.human || version.item_type
    t("subjects.#{key}", label: label, default: t("subjects.default", label: label, model: model))
  end

  def event_sentence
    key = case event
    when "sign_in_failed"
      if version.item_id.nil? then "sign_in_failed_unknown"
      elsif %w[locked inactive].include?(details["reason"]) then "sign_in_failed_#{details['reason']}"
      else event
      end
    when "teacher_sign_in_failed" then version.item_id ? event : "teacher_sign_in_failed_unknown"
    when "password_changed" then own_record? ? "password_changed_own" : event
    else event
    end

    t("events.#{key}", item: label, email: details["email"], attempts: details["attempts"], id_number: details["id_number"],
                       list: details["list"], to: details["to"],
                       rows: ActiveSupport::NumberHelper.number_to_delimited(details["rows"].to_i, delimiter: "."),
                       default: event.humanize)
  end

  def own_record?
    version.actor_type == version.item_type && version.whodunnit == version.item_id.to_s
  end

  def change_lines
    (version.object_changes || {}).except(*HIDDEN_FIELDS).map do |field, (before, after)|
      label = item_class ? item_class.human_attribute_name(field) : field.humanize
      if long_text?(before) || long_text?(after)
        Line.new(label, t("long_text"))
      else
        Line.new(label, format_value(field, before), format_value(field, after))
      end
    end
  end

  def permission_lines
    [
      (Line.new(t("permissions.added"), permission_names(details["added"])) if details["added"].present?),
      (Line.new(t("permissions.removed"), permission_names(details["removed"])) if details["removed"].present?)
    ].compact
  end

  def permission_names(tokens)
    Array(tokens).map do |token|
      parsed = UserPermission.parse_token(token)
      [ UserPermission.resource_label(parsed[:resource_name]), UserPermission::ACTION_LABELS[parsed[:action_name]] || "todo" ].join(" · ")
    end.join(", ")
  end

  def teacher_lines
    (details["changes"] || {}).map do |field, (before, after)|
      label = t("teacher_fields.#{field}", default: field.humanize)
      long_text?(before) || long_text?(after) ? Line.new(label, t("long_text")) : Line.new(label, blank(before), blank(after))
    end
  end

  def export_lines
    lines = [ Line.new(t("export.filters"), details["filters"].to_s.delete_prefix("Filtros: ")) ]
    lines << Line.new(t("export.peer_reviews"), t("export.included")) if details["peer_reviews"]
    lines
  end

  def format_value(field, value)
    return blank(value) if value.nil? || value == ""
    return t("booleans.#{version.item_type.to_s.underscore}.#{value}", default: value ? "Sí" : "No") if [ true, false ].include?(value)
    return enum_value(field, value) if item_class&.defined_enums&.key?(field)
    return associated_label(field, value) if field.end_with?("_id")

    date_value(value) || value.to_s
  end

  def enum_value(field, value)
    key = item_class.defined_enums[field].key(value) || value.to_s
    I18n.t("enums.#{item_class.model_name.i18n_key}.#{field}.#{key}", default: key.to_s.humanize)
  end

  def associated_label(field, id)
    reflection = item_class&.reflect_on_all_associations(:belongs_to)&.find { |association| association.foreign_key.to_s == field }
    record = reflection&.klass&.find_by(id: id) unless reflection&.polymorphic?
    record ? record.audit_label : "n.º #{id}"
  end

  def date_value(value)
    case value.to_s
    when /\A\d{4}-\d{2}-\d{2}\z/ then I18n.l(Date.iso8601(value), format: "%d/%m/%Y")
    when /\A\d{4}-\d{2}-\d{2}T/
      time = Time.zone.parse(value)
      I18n.l(time, format: time.seconds_since_midnight.zero? ? "%d/%m/%Y" : "%d/%m/%Y %H:%M")
    end
  rescue ArgumentError
    nil
  end

  def long_text?(value)
    value.is_a?(String) && value.length > LONG_TEXT
  end

  def blank(value)
    value.presence || t("empty")
  end

  def item_class
    @item_class ||= version.item_type&.safe_constantize
  end

  def t(key, **options)
    I18n.t("audit.#{key}", **options)
  end
end
