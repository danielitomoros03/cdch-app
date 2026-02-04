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

  def nosotros
    @departments = Department.all.order(created_at: :desc)
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
    @department = Department.find_by!(acronym: params[:acronym])
  end
  
  def contacto
  end
end
