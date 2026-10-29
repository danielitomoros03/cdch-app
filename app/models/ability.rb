# frozen_string_literal: true

class Ability
  include CanCan::Ability

  # Investigadores y su historia en el CDCH: datos personales de uso interno. Por
  # ahora solo los ven Dirección, Subdirección y Superadmin (desarrollo), y nadie
  # los edita: se cargan con `rails cdch:import`. Los permisos por departamento
  # (DADI, DADA...) vendrán después.
  RESEARCH_RECORDS = [
    Person, PersonContact, UcvAppointment, PpiLevel,
    ResearchProject, ProjectStage, StageCoInvestigator, StagePublication, StageExtension,
    InstitutionalAid, Scholarship
  ].freeze
  RESEARCH_READERS = %w[Director Subdirector Superadmin].freeze
  # Los arbitrajes son confidenciales: ni DTIC (Superadmin) ni docentes, solo la Dirección.
  PEER_REVIEW_READERS = %w[Director Subdirector].freeze

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

      # Directors/Subdirectors are read-only by default; explicit UserPermission
      # for InstitutionLeadership must enable actions like create/update.
      if resource_class == InstitutionLeadership
        can permission_action, InstitutionLeadership
        next
      end

      if resource_class.column_names.include?("department_id")
        can permission_action, resource_class, department_id: department_id
      else
        can permission_action, resource_class
      end
    end

    # Va al final para pisar los `:manage, :all` de Superadmin y de la jefatura de DTIC.
    cannot :manage, [ *RESEARCH_RECORDS, PeerReview ]
    can :read, RESEARCH_RECORDS if role == "Superadmin" && RESEARCH_READERS.include?(job_title_name)
    can :read, PeerReview if role == "Superadmin" && PEER_REVIEW_READERS.include?(job_title_name)
  end
end
