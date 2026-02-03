# frozen_string_literal: true

class Ability
  include CanCan::Ability

  
  def initialize(user)
    # user ||= User.new # User invited but not logged in
    # 1. Director / Superadmin makes ABSOLUTELLY EVERYTHING 
    if user.role == "Superadmin" || user.role == 3
      can :manage, :all
      
    # 2. System's Administrator
    elsif user.role == "Administrador" || user.role == 2
      # Puedes excluir configuraciones críticas si quieres diferenciarlo del Director
      can :read, :all
      can :edit, [User, Department, Call, Minute, Publication, Event]
      can :update, [User, Department, Call, Minute, Publication, Event]
      
    # 3. Department's Coordinator
    elsif user.role == "Coordinador" || user.role == 1
      # Solo puede crear/editar usuarios de SU mismo departamento
      can :read, Department, department_id: user.department_id
      can :read, Call, department_id: user.department_id
      can :read, Minute, department_id: user.department_id
      can :read, Publication, department_id: user.department_id
      can :read, Event, department_id: user.department_id
      can :manage, User, department_id: user.department_id
      
    # 4. Regular User
    else
      can :read, :all, department_id: user.department_id
      can :update, User, id: user.id # Only update their own profile
      can :update, Department, id: user.department_id # Only update their own department's profile
    end
  end
end
