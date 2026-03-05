module Dashboard
  class MinutesController < ApplicationController
    before_action :set_minute, only: %i[ show edit update destroy ]
    load_and_authorize_resource ## Authorization for Cancancan

    # GET /minutes or /minutes.json
    def index
      @minutes = Minute.accessible_by(current_ability).order(created_at: :desc)
    end

    # GET /minutes/1 or /minutes/1.json
    def show
    end

    # GET /minutes/new
    def new
      @minute = Minute.new
    end

    # GET /minutes/1/edit
    def edit
    end

    # POST /minutes or /minutes.json
    def create
      @minute = Minute.new(minute_params)

      respond_to do |format|
        if @minute.save
          format.html { redirect_to @minute, notice: "Acta creada correctamente." }
          format.json { render :show, status: :created, location: @minute }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @minute.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /minutes/1 or /minutes/1.json
    def update
      respond_to do |format|
        if @minute.update(minute_params)
          format.html { redirect_to @minute, notice: "Acta actualizada correctamente." }
          format.json { render :show, status: :ok, location: @minute }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @minute.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /minutes/1 or /minutes/1.json
    def destroy
      @minute.destroy!

      respond_to do |format|
        format.html { redirect_to minutes_path, status: :see_other, notice: "Acta eliminada correctamente." }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_minute
        @minute = Minute.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def minute_params
        params.require(:minute).permit(:day, :title, :description, :content, :attachment_minute)
      end
  end
end
