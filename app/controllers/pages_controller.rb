class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  def eventos
    if params[:id]
      @event = Event.find(params[:id])
      render :evento
    else
      @eventsActive = Event.where(active: true).order(day: :desc)
      @eventsInactive = Event.where(active: false).order(day: :desc)
    end
  end

  def inicio
    @fourDepartments = Department.all.order(organize: :asc).limit(4)
    @events = Event.where(active: true).order(day: :desc).limit(4) # Filter for last edited active events
    @eventsHero = @events.where(show_in: true).order(day: :desc).limit(3) # Filter for events to show in hero section
    @featured_publications = Publication.with_attached_portrait
                                        .with_attached_publication_field
                                        .order(created_at: :desc)
                                        .limit(4)
    if params[:id]
      @event = Event.find(params[:id])
      render :evento
    else
      @eventsActive = Event.where(active: true).order(day: :desc)
      @eventsInactive = Event.where(active: false).order(day: :desc)
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

  def galeria_autoridades
    @institution = Institution.first

    if @institution.present?
      @directors = @institution.institution_leaderships
                              .director
                              .includes(photo_attachment: :blob)
                              .ordered_for_gallery

      @subdirectors = @institution.institution_leaderships
                                 .subdirector
                                 .includes(photo_attachment: :blob)
                                 .ordered_for_gallery
    else
      @directors = InstitutionLeadership.none
      @subdirectors = InstitutionLeadership.none
    end
  end

  def galeria_autoridades_v2
    @institution = Institution.first

    if @institution.present?
      directors = @institution.institution_leaderships
                              .director
                              .includes(photo_attachment: :blob)
                              .ordered_for_gallery
                              .to_a

      subdirectors = @institution.institution_leaderships
                                 .subdirector
                                 .includes(photo_attachment: :blob)
                                 .ordered_for_gallery
                                 .to_a

      @groups = build_authority_timeline_groups(directors, subdirectors)
    else
      @groups = []
    end
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
    if params[:id]
      @publication = Publication.with_attached_portrait
                                .with_attached_publication_field
                                .find(params[:id])
      render :publicacion
    else
      @publications = Publication.with_attached_portrait
                                 .with_attached_publication_field
                                 .order(created_at: :desc)
                                 .limit(8)
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to publicaciones_path, alert: "Publicacion no encontrada."
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

  private

  def build_authority_timeline_groups(directors, subdirectors)
    groups = []
    remaining = subdirectors.dup
    infinity = Date.new(9999, 12, 31)

    directors.each do |director|
      dir_end = director.end_date || infinity

      matching = remaining.select do |sub|
        sub_end = sub.end_date || infinity
        director.start_date <= sub_end && sub.start_date <= dir_end
      end

      remaining -= matching
      groups << { director: director, subdirectors: matching }
    end

    remaining.each { |sub| groups << { director: nil, subdirectors: [sub] } }

    groups
  end
end
