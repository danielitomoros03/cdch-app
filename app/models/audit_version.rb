# Una línea de la bitácora: un cambio guardado por PaperTrail o un evento registrado con
# `Audit.record`. Nunca se edita ni se borra desde la app. La lee AuditEntry para mostrarla.
# == Schema Information
#
# Table name: versions
#
#  id             :bigint           not null, primary key
#  actor_label    :string
#  actor_type     :string
#  browser        :string
#  details        :jsonb            not null
#  event          :string           not null
#  ip             :string
#  item_label     :string
#  item_type      :string
#  location       :string
#  object         :jsonb
#  object_changes :jsonb
#  os             :string
#  sensitive      :boolean          default(FALSE), not null
#  whodunnit      :string
#  created_at     :datetime         not null
#  item_id        :bigint
#  request_id     :string
#
# Indexes
#
#  index_versions_on_actor_type_and_whodunnit  (actor_type,whodunnit)
#  index_versions_on_created_at                (created_at)
#  index_versions_on_event                     (event)
#  index_versions_on_item_type_and_item_id     (item_type,item_id)
#
class AuditVersion < ApplicationRecord
  include PaperTrail::VersionConcern
  self.table_name = "versions"

  before_create { self.sensitive = true if event == "destroy" }

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }
  scope :sensitive_only, -> { where(sensitive: true) }
  scope :by_actor, ->(type, id) { where(actor_type: type, whodunnit: id.to_s) }
  scope :between, ->(from, to) { where(created_at: (from&.beginning_of_day)..(to&.end_of_day)) }

  def readonly?
    persisted?
  end
end
