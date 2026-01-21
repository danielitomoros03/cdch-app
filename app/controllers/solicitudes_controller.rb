class SolicitudesController < ApplicationController
  # POST /solicitudes
  def create
    @solicitude = Solicitude.new(solicitude_params)

    respond_to do |format|
      if @solicitude.save
        format.html { redirect_to contacto_path, notice: "Su solicitud ha sido enviada exitosamente. Recibirá una respuesta por correo electrónico o mensaje telefónico en las próximas horas." }
        format.json { render json: { message: "Solicitud enviada" }, status: :created }
      else
        format.html { redirect_to contacto_path, alert: "Error al enviar la solicitud. Por favor, revise los datos e intente nuevamente." }
        format.json { render json: @solicitude.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def solicitude_params
    params.require(:solicitude).permit(:full_name, :email, :phone_number, :matter, :message, :policies)
  end
end