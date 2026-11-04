module Dashboard
  # Publicaciones de Saber de una persona, dentro de la pestaña de su ficha (marco Turbo):
  # filtros por tipo y año y paginación.
  class SaberPublicationsController < ApplicationController
    def index
      @person = Person.find(params[:person_id])
      authorize! :read, @person
      @list = SaberPublicationList.new(@person.saber_authorships.accepted, kind: params[:tipo], year: params[:anio], page: params[:page])
    end
  end
end
