class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Bitácora: guarda cada alta, cambio y baja del modelo con PaperTrail, con el nombre
  # legible del registro. `sensitive: true` marca todos sus cambios como sensibles.
  def self.audited(sensitive: false, **options)
    has_paper_trail(**options, versions: { class_name: "AuditVersion" }, meta: { item_label: :audit_label, sensitive: sensitive })
  end

  # Nombre con el que el registro aparece en la bitácora.
  def audit_label
    %i[display_name full_name title name].each do |method|
      value = public_send(method) if respond_to?(method)
      return value.to_s.squish.truncate(90) if value.present?
    end
    "#{model_name.human} n.º #{id}"
  end
end
