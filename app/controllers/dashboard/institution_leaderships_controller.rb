module Dashboard
  class InstitutionLeadershipsController < ApplicationController
    before_action :set_institution_leadership, only: %i[show edit update destroy]
    before_action :set_collections, only: %i[new create edit update]
    load_and_authorize_resource

    def index
      @institution_leaderships = InstitutionLeadership
                                .includes(:institution)
                                .accessible_by(current_ability)
                                .ordered_for_gallery
    end

    def show
    end

    def new
      @institution_leadership = InstitutionLeadership.new
    end

    def edit
    end

    def create
      @institution_leadership = InstitutionLeadership.new(institution_leadership_params)

      if @institution_leadership.save
        redirect_to institution_leadership_path(@institution_leadership), notice: "Autoridad registrada correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @institution_leadership.update(institution_leadership_params)
        redirect_to institution_leadership_path(@institution_leadership), notice: "Autoridad actualizada correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @institution_leadership.destroy
      redirect_to institution_leaderships_path, status: :see_other, notice: "Autoridad eliminada correctamente."
    end

    private

    def set_institution_leadership
      @institution_leadership = InstitutionLeadership.find(params[:id])
    end

    def set_collections
      @institutions = Institution.accessible_by(current_ability).order(:name)
      return unless defined?(@institution_leadership) && @institution_leadership.present?

      @institutions = @institutions.or(Institution.where(id: @institution_leadership.institution_id))
    end

    def institution_leadership_params
      params.require(:institution_leadership).permit(
        :institution_id,
        :role,
        :full_name,
        :start_date,
        :end_date,
        :photo,
        :bio
      )
    end
  end
end
