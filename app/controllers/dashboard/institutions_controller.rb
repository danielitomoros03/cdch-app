module Dashboard
  class InstitutionsController < ApplicationController
    before_action :set_institution, only: %i[ show edit update ]

    # GET /institutions or /institutions.json
    def index
      @institutions = Institution.all
    end

    # GET /institutions/1 or /institutions/1.json
    def show
    end

    # GET /institutions/1/edit
    def edit
    end

    # PATCH/PUT /institutions/1 or /institutions/1.json
    def update
      respond_to do |format|
        if @institution.update(institution_params)
          format.html { redirect_to @institution, notice: "Datos de la institución correctamente actualizados." }
          format.json { render :show, status: :ok, location: @institution }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @institution.errors, status: :unprocessable_entity }
        end
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_institution
        @institution = Institution.first
      end

      # Only allow a list of trusted parameters through.
      def institution_params
        params.require(:institution).permit(:address, :name, :primary_phone, :secondary_phone, :primary_email, :secondary_email, :business_hours, :mission, :vission, :twitter_url, :facebook_url, :instagram_url, :threads_url, :acronym, :description, :linkedin_url, :director_name, :director_primary_email, :director_secondary_email, :subdirector_name, :subdirector_primary_email, :subdirector_secondary_email, :founded_year, :logoInstitution, :remove_logo, :history)
      end
  end
end
