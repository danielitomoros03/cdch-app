# Interruptores de funciones del sistema, a cargo de la DTIC (Configuración general).
# Los datos secretos, como la clave del correo, no van aquí: son variables del servidor.
# == Schema Information
#
# Table name: general_setups
#
#  id                     :bigint           not null, primary key
#  email_delivery_enabled :boolean          default(FALSE), not null
#  singleton              :integer          default(1), not null
#  teacher_space_enabled  :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  updated_by_id          :bigint
#
# Indexes
#
#  index_general_setups_on_singleton      (singleton) UNIQUE
#  index_general_setups_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (updated_by_id => users.id)
#
class GeneralSetup < ApplicationRecord
  belongs_to :updated_by, class_name: "User", optional: true

  def self.current
    first || create!
  rescue ActiveRecord::RecordNotUnique
    first
  end

  def self.teacher_space? = current.teacher_space_enabled?

  def self.email_delivery? = current.email_delivery_enabled?

  # El servidor de correo se define con variables de entorno (SMTP_ADDRESS, SMTP_USERNAME, SMTP_PASSWORD).
  def self.smtp_address
    ENV["SMTP_ADDRESS"].presence
  end
end
