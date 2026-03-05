# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    # Normalize role and acronym to avoid mismatches by type/case/whitespace.
    role = user.role.is_a?(Integer) ? JobTitle.roles.key(user.role) : user.role.to_s
    job_title_name = user.job_title&.name
    department_id = user.department_id
    department_acronym = user.department&.acronym.to_s.strip.upcase

    case role
    when "Superadmin"
      if ["Director", "Subdirector"].include?(job_title_name)
        can :read, :all
      else
        can :manage, :all
      end
    when "Administrador"
      can :manage, Department, id: department_id
    when "JefeDepartamento"
      if department_acronym == "DTIC"
        can :manage, :all
      else
        can :read, Department, id: department_id
      end
    when "Coordinador"
      can :read, Department, id: department_id
    else
      can :read, User, department_id: department_id
      can :read, Department, id: department_id
    end

    full_user_management = role == "Superadmin" || (role == "JefeDepartamento" && department_acronym == "DTIC")

    unless full_user_management
      cannot :manage, User
      can :read, User, department_id: department_id
    end


    user.user_permissions.each do |permission|
      resource_class = permission.resource_class
      permission_action = permission.permission_action
      next unless resource_class && permission_action

      if resource_class.column_names.include?("department_id")
        can permission_action, resource_class, department_id: department_id
      else
        can permission_action, resource_class
      end
    end
  end
end
