# == Schema Information
#
# Table name: solicitudes
#
#  id           :bigint           not null, primary key
#  email        :string
#  full_name    :string
#  matter       :integer
#  message      :text
#  phone_number :string
#  policies     :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Solicitude < ApplicationRecord
  audited

  validates :full_name, :email, :phone_number, :matter, :message, :policies, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :policies, acceptance: true

  # La misma persona con el mismo mensaje en el último día: se reenvió porque no vio la confirmación.
  def duplicate?
    return false if email.blank? || message.blank?

    self.class.where("lower(email) = ?", email.strip.downcase)
              .where(created_at: 1.day.ago..)
              .any? { |other| other.message.squish == message.squish }
  end
end
