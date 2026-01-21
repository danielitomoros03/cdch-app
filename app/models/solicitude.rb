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
  validates :full_name, :email, :phone_number, :matter, :message, :policies, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :policies, acceptance: true
end
