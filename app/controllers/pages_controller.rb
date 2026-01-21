class PagesController < ApplicationController
  def inicio
  end

  def nosotros
    @departments = Department.all
  end
  
  def investigacion
  end
  
  def convocatorias
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
