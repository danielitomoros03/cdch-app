class PagesController < ApplicationController
  def inicio
  end

  def nosotros
    @departments = Department.all
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
  end
  
  def directorio
  end
  
  def departamento
    @department = Department.find_by!(acronym: params[:acronym])
  end
  
  def contacto
  end
end
