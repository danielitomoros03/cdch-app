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
      can :read, :all
      # Admin can manage resources within their own department
      can :manage, [Call, Minute, Publication, Event], department_id: department_id
      can :manage, [User, Department], department_id: department_id
    when "JefeDepartamento"
      can :read, :all, department_id: department_id
      can :manage, [Call, Minute, Publication, Event], department_id: department_id
      can :manage, [User], department_id: department_id
    when "Coordinador"
      can :read, :all, department_id: department_id
      can [:create, :update], [Call, Minute, Publication, Event], department_id: department_id
      can [:create, :update], [User], department_id: department_id
    else
      can :read, [Call, Minute, Publication, Event], department_id: department_id
      can :read, Department, id: department_id
      can :update, User, id: user.id
    end


    #user.user_permissions.each do |permission|
    #  resource_class = permission.resource_class
    #  next unless resource_class

    #  can :manage, resource_class
    #end
  end
end
