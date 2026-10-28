module Dashboard
  # Docentes e investigadores: listado con filtros y ficha. Solo lectura.
  class PeopleController < ApplicationController
    load_and_authorize_resource

    PER_PAGE = 50

    def index
      @faculties = Faculty.order(:code)
      @filters = params.permit(:q, :situation, :faculty, :history, :since).to_h.symbolize_keys

      people = Person.accessible_by(current_ability)
      people = people.search(@filters[:q]) if @filters[:q].present?
      people = people.in_situation(@filters[:situation]) if Person::SITUATIONS.key?(@filters[:situation])
      people = people.in_faculty(@filters[:faculty]) if @filters[:faculty].present?
      people = people.with_cdch_history if @filters[:history] == "1"
      people = people.with_projects_since(@filters[:since]) if @filters[:since].to_s.match?(/\A(19|20)\d\d\z/)

      @total = people.count
      @people = people.order(:full_name).paginate(page: params[:page], per_page: PER_PAGE)
      @appointments = UcvAppointment.where(person_id: @people.map(&:id)).group_by(&:person_id)
      @faculty_names = @faculties.to_h { |faculty| [ faculty.code, faculty.name ] }
      @stage_counts = ProjectStage.where(lead_person_id: @people.map(&:id)).group(:lead_person_id).count
      @co_counts = StageCoInvestigator.where(person_id: @people.map(&:id)).group(:person_id).count
    end

    def show
      @faculty_names = Faculty.pluck(:code, :name).to_h
      @appointments = @person.ucv_appointments.order(hired_on: :desc)
      @contacts = @person.contacts.order(:kind, :value)
      @led_stages = @person.led_stages.includes(:research_project, :legacy_status).order(requested_on: :desc)
      @co_stages = @person.co_investigations.includes(project_stage: [ :research_project, :lead_person ]).order(stage_number: :desc)
      @aids = @person.institutional_aids.includes(:legacy_status).order(requested_on: :desc)
      @scholarships = @person.scholarships.order(starts_on: :desc)
      @ppi_levels = @person.ppi_levels
    end
  end
end
