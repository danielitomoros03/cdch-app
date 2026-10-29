module Dashboard
  # Docentes e investigadores: listado con filtros, ficha y exportación a Excel. Solo lectura.
  class PeopleController < ApplicationController
    include ZipKit::RailsStreaming

    load_and_authorize_resource

    # Pocas filas para que la paginación se vea sin desplazarse.
    PER_PAGE = 12

    def index
      @faculties = Faculty.order(:code)
      @filters = params.permit(:q, :situation, :faculty, :history, :since).to_h.symbolize_keys
      people = filtered_people

      respond_to do |format|
        format.html do
          @total = people.count
          @people = people.alphabetical.paginate(page: params[:page], per_page: PER_PAGE)
          @appointments = UcvAppointment.where(person_id: @people.map(&:id)).group_by(&:person_id)
          @faculty_names = @faculties.to_h { |faculty| [ faculty.code, faculty.name ] }
          @stage_counts = ProjectStage.where(lead_person_id: @people.map(&:id)).group(:lead_person_id).count
          @co_counts = StageCoInvestigator.where(person_id: @people.map(&:id)).group(:person_id).count
        end
        format.xlsx { stream_spreadsheet(people) }
      end
    end

    def show
      @faculty_names = Faculty.pluck(:code, :name).to_h
      @appointments = @person.ucv_appointments.order(hired_on: :desc)
      @contacts = @person.contacts.order(Arel.sql("source = 'docente' DESC"), :kind, :value)
      @led_stages = @person.led_stages.includes(:research_project, :legacy_status).order(requested_on: :desc)
      @co_stages = @person.co_investigations.includes(project_stage: [ :research_project, :lead_person ]).order(stage_number: :desc)
      @aids = @person.institutional_aids.includes(:legacy_status).order(requested_on: :desc)
      @scholarships = @person.scholarships.order(starts_on: :desc)
      @ppi_levels = @person.ppi_levels
      @reviews = @person.peer_reviews_given.accessible_by(current_ability).includes(project_stage: :research_project).order(sent_on: :desc) if can?(:read, PeerReview)
    end

    private

    def filtered_people
      people = Person.accessible_by(current_ability)
      people = people.search(@filters[:q]) if @filters[:q].present?
      people = people.in_situation(@filters[:situation]) if Person::SITUATIONS.key?(@filters[:situation])
      people = people.in_faculty(@filters[:faculty]) if @filters[:faculty].present?
      people = people.with_cdch_history if @filters[:history] == "1"
      people = people.with_projects_since(@filters[:since]) if @filters[:since].to_s.match?(/\A(19|20)\d\d\z/)
      people
    end

    # El archivo se escribe mientras se descarga, en tandas de personas: no se arma en memoria.
    def stream_spreadsheet(people)
      export = PeopleExport.new(people.alphabetical, faculties: @faculties, filters: @filters, reviews: can?(:read, PeerReview))
      zip_kit_stream(filename: export.filename, type: Mime[:xlsx].to_s) do |zip|
        export.write(zip)
      end
    end
  end
end
