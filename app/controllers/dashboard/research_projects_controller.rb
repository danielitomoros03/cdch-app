module Dashboard
  # Proyecto del sistema heredado con todas sus etapas. Solo lectura.
  class ResearchProjectsController < ApplicationController
    load_and_authorize_resource

    def show
      @faculty_names = Faculty.pluck(:code, :name).to_h
      @stages = @research_project.stages.includes(:lead_person, :legacy_status, :funding_source, :publications, :extensions, co_investigators: :person)
      @reviews_by_stage = if can?(:read, PeerReview)
        PeerReview.accessible_by(current_ability).where(project_stage: @stages).includes(:reviewer_person).order(:sent_on).group_by(&:project_stage_id)
      end
    end
  end
end
