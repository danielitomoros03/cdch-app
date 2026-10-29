module Dashboard
  # Configuración general: la DTIC enciende o apaga funciones del sistema.
  class GeneralSetupsController < ApplicationController
    before_action :set_general_setup

    def show
      authorize! :read, @general_setup
    end

    def update
      authorize! :update, @general_setup
      @general_setup.update!(general_setup_params.merge(updated_by: current_user))
      redirect_to general_setup_path, notice: "Guardamos la configuración."
    end

    # Manda un correo al usuario que pulsa el botón, aunque el envío general esté apagado.
    def test_email
      authorize! :update, @general_setup
      SystemMailer.with(force: true).test_message(current_user.email).deliver_now
      redirect_to general_setup_path, notice: "Enviamos un correo de prueba a #{current_user.email}. Revisa también la carpeta de spam."
    rescue StandardError => error
      redirect_to general_setup_path, alert: "No se pudo enviar el correo de prueba: #{error.class.name.demodulize} (#{error.message.truncate(120)})."
    end

    private

    def set_general_setup
      @general_setup = GeneralSetup.current
    end

    def general_setup_params
      params.require(:general_setup).permit(:teacher_space_enabled, :email_delivery_enabled)
    end
  end
end
