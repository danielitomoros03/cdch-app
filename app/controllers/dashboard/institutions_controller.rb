module Dashboard
  class InstitutionsController < ApplicationController
    before_action :set_institution, only: %i[ show edit update destroy ]

    # GET /institutions or /institutions.json
    def index
      @institution = Institution.first
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
          format.html { redirect_to @institution, notice: "Institution was successfully updated." }
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
        @institution = Institution.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def institution_params
        params.require(:institution).permit(:address, :name, :primary_phone, :secondary_phone, :primary_email, :secondary_email, :business_hours, :mission, :vission, :twitter_url, :facebook_url, :instagram_url, :threads_url, :acronym, :description, :linkedin_url, :director_name, :director_email, :founded_year, :logoInstitution, :history)
      end
  end
end
