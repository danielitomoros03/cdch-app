class SolicitudesController < ApplicationController
  skip_before_action :authenticate_user!

  SENT = "Recibimos su solicitud. Le responderemos por correo electrónico o por teléfono en las próximas horas.".freeze
  ALREADY_SENT = "Ya habíamos recibido esta solicitud; no hace falta enviarla de nuevo. Le responderemos por correo electrónico o por teléfono.".freeze
  INVALID = "No pudimos enviar la solicitud. Revise que todos los campos estén completos y que haya aceptado las políticas de privacidad.".freeze
  TOO_MANY = "Recibimos varias solicitudes seguidas desde su conexión. Inténtelo de nuevo en una hora.".freeze

  # Campo oculto que una persona no ve ni llena; los robots que rellenan todo, sí.
  HONEYPOT = :website
  # Enlaces en HTML: ninguna consulta real los trae y casi todo el spam recibido, sí.
  SPAM_MARKUP = /<\s*a\b|href\s*=|<\s*b\s*>/i

  rate_limit to: 5, within: 1.hour, only: :create, with: -> { redirect_to contact_form_path, alert: TOO_MANY }

  # POST /solicitudes
  def create
    # Al robot se le responde como si todo hubiera salido bien, para que no insista.
    return redirect_to(contact_form_path, notice: SENT) if spam?

    @solicitude = Solicitude.new(solicitude_params)
    return redirect_to(contact_form_path, notice: ALREADY_SENT) if @solicitude.duplicate?

    if @solicitude.save
      redirect_to contact_form_path, notice: SENT
    else
      redirect_to contact_form_path, alert: INVALID
    end
  end

  private

  def solicitude_params
    params.require(:solicitude).permit(:full_name, :email, :phone_number, :matter, :message, :policies)
  end

  def spam?
    params.dig(:solicitude, HONEYPOT).present? || params.dig(:solicitude, :message).to_s.match?(SPAM_MARKUP)
  end

  # Vuelve al formulario y no al principio de la página, para que el aviso se vea.
  def contact_form_path
    contacto_path(anchor: "mensaje")
  end
end
