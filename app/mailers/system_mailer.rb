# Correos del propio sistema; por ahora, la prueba de envío de la Configuración general.
class SystemMailer < ApplicationMailer
  # Con `force: true` sale aunque el envío general esté apagado (ver MailDeliveryGate).
  def test_message(to)
    headers[MailDeliveryGate::FORCE_HEADER] = "1" if params&.dig(:force)
    mail(to: to, subject: "Prueba de envío · CDCH-UCV")
  end
end
