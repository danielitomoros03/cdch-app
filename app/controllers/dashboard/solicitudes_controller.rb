module Dashboard
  class SolicitudesController < ApplicationController
    before_action :set_solicitude, only: %i[ show ]

    # GET /solicitudes or /solicitudes.json
    def index
      @solicitudes = Solicitude.all.order(created_at: :desc)
    end

    # GET /solicitudes/1 or /solicitudes/1.json
    def show
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_solicitude
        @solicitude = Solicitude.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def solicitude_params
        params.require(:solicitude).permit(:full_name, :email, :phone_number, :matter, :message, :policies)
      end
  end
end
