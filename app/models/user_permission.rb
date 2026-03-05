# == Schema Information
#
# Table name: user_permissions
#
#  id         :bigint           not null, primary key
#  resource   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_permissions_on_user_id               (user_id)
#  index_user_permissions_on_user_id_and_resource  (user_id,resource) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class UserPermission < ApplicationRecord
  belongs_to :user

  RESOURCE_MAP = {
    "Call" => Call,
    "Event" => Event,
    "Publication" => Publication,
    "Minute" => Minute,
    "Solicitude" => Solicitude
  }.freeze

  RESOURCE_LABELS = {
    "Call" => "Convocatorias",
    "Event" => "Eventos",
    "Publication" => "Publicaciones",
    "Minute" => "Actas",
    "Solicitude" => "Solicitudes"
  }.freeze

  ACTION_MAP = {
    "read" => :read,
    "create" => :create,
    "update" => :update
  }.freeze

  ACTION_LABELS = {
    "read" => "Ver",
    "create" => "Crear",
    "update" => "Editar"
  }.freeze

  validates :resource, presence: true
  validate :resource_token_must_be_valid

  def self.permission_token(resource_name, action_name)
    "#{resource_name}:#{action_name}"
  end

  def self.resource_label(resource_name)
    RESOURCE_LABELS[resource_name] || resource_name
  end

  def self.valid_token?(token)
    parsed = parse_token(token)
    parsed[:resource_name].present? && parsed[:permission_action].present?
  end

  def self.expand_tokens(tokens)
    Array(tokens).flat_map do |token|
      parsed = parse_token(token)
      next [] if parsed[:resource_name].blank? || parsed[:permission_action].blank?

      if parsed[:legacy]
        ACTION_MAP.keys.map { |action_name| permission_token(parsed[:resource_name], action_name) }
      else
        [permission_token(parsed[:resource_name], parsed[:action_name])]
      end
    end.uniq
  end

  def self.parse_token(token)
    raw_token = token.to_s
    resource_name, action_name = raw_token.split(":", 2)

    if action_name.present?
      {
        resource_name: RESOURCE_MAP.key?(resource_name) ? resource_name : nil,
        action_name: ACTION_MAP.key?(action_name) ? action_name : nil,
        permission_action: ACTION_MAP[action_name],
        legacy: false
      }
    else
      {
        resource_name: RESOURCE_MAP.key?(resource_name) ? resource_name : nil,
        action_name: nil,
        permission_action: RESOURCE_MAP.key?(resource_name) ? :manage : nil,
        legacy: true
      }
    end
  end

  def parsed_token
    @parsed_token ||= self.class.parse_token(resource)
  end

  def resource_name
    parsed_token[:resource_name]
  end

  def permission_action
    parsed_token[:permission_action]
  end

  def action_name
    parsed_token[:action_name]
  end

  def resource_class
    RESOURCE_MAP[resource_name]
  end

  private

  def resource_token_must_be_valid
    errors.add(:resource, "no es válido") unless self.class.valid_token?(resource)
  end
end
