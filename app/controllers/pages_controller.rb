class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  def eventos
    if params[:id]
      @event = Event.find(params[:id])
      render :evento
    else
      @eventsActive = Event.where(active: true).order(day: :asc)
      @eventsInactive = Event.where(active: false).order(day: :asc)
    end
  end

  def inicio
    @fourDepartments = Department.all.order(organize: :asc).limit(4)
    @events = Event.where(active: true).order(day: :desc).limit(4) # Filter for last edited active events
    @eventsHero = @events.where(show_in: true).order(day: :desc).limit(3) # Filter for events to show in hero section
    if params[:id]
      @event = Event.find(params[:id])
      render :evento
    else
      @eventsActive = Event.where(active: true).order(day: :asc)
      @eventsInactive = Event.where(active: false).order(day: :asc)
    end
  end

  def direccion
    @direction = Department.last

    director_role = JobTitle.find_by(name: "Director")
    direction_users = User.includes(:job_title).where(department_id: @direction.id)
    direction_users = direction_users.where.not(job_title_id: director_role.id) if director_role.present?

    # Personal de apoyo adscrito a la Direccion (vigilancia y limpieza).
    @support_staff = direction_users
                     .joins(:job_title)
                     .where(
                       "LOWER(job_titles.name) LIKE :vigilance OR LOWER(job_titles.name) LIKE :cleaning OR LOWER(job_titles.name) LIKE :maintenance",
                       vigilance: "%vigil%",
                       cleaning: "%limpiez%",
                       maintenance: "%aseo%"
                     )
                     .order("job_titles.name ASC, users.lastname ASC, users.name ASC")

    @other_users = direction_users.where.not(id: @support_staff.select(:id))
  end
  
  def subdireccion
    @subdirection = Department.find_by!(acronym: "Subdir")
    @other_users = User.where(department_id: @subdirection.id).where.not(job_title_id: JobTitle.find_by(name: "Subdirector").id)
  end
  
  def nosotros
    @departments = Department.all.order(organize: :asc).limit(8)
    @secretariesDir = User.where(department_id: Department.last).where(job_title_id: JobTitle.find_by(name: "Secretario(a)").id)
    @secretariesSubdir = User.where(department_id: Department.find_by!(acronym: "Subdir")).where(job_title_id: JobTitle.find_by(name: "Secretario(a)").id)
  end
  
  def investigacion
  end
  
  def convocatorias
    if params[:id]
      @call = Call.find(params[:id])
      render :convocatoria
    else
      @callsActive = Call.where(active: true).order(created_at: :desc)
      @callsInactive = Call.where(active: false).order(created_at: :desc)
    end
  end

  def publicaciones
    @publications = Publication.all.order(created_at: :desc).limit(8)
  end
  
  def directorio
    if params[:id]
      @minute = Minute.find(params[:id])
      render :acta
    else
      @minutes = Minute.paginate(page: params[:page], per_page: 8).order(day: :desc)
    end
  end
  
  def departamento
    @department = Department.find_by(acronym: params[:acronym])
    return redirect_to(root_path, alert: "Departamento no encontrado.") if @department.nil?

    jefe_role = JobTitle.find_by(name: "Jefe de Departamento")

    base_users = User.joins(:job_title)
                     .where(department_id: @department.id)
                     .where.not(job_titles: { role: JobTitle.roles[:Superadmin] })

    if jefe_role
      @jefe = User.find_by(department_id: @department.id, job_title_id: jefe_role.id)
      @others = base_users.where.not(job_title_id: jefe_role.id)
                          .order(job_title_id: :asc)
    else
      @jefe = nil
      @others = base_users.order(job_title_id: :asc)
    end
  
    if params[:acronym] == "Subdir" 
      redirect_to subdireccion_path
    elsif params[:acronym] == "Dir"
      redirect_to direccion_path
    end
  end
  
  def contacto
  end
end
