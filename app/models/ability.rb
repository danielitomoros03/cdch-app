# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    role = user.role
    job_title_name = user.job_title&.name
    department_id = user.department_id

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
      if user.department&.acronym == "DTIC"
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

    unless role == "Superadmin"
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
