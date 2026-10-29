# Ningún correo sale mientras la DTIC no active el envío en la Configuración general,
# salvo la prueba que se pide a propósito desde esa misma pantalla.
class MailDeliveryGate
  FORCE_HEADER = "X-CDCH-Delivery-Test".freeze

  def self.delivering_email(message)
    forced = message.header[FORCE_HEADER].present?
    message.header[FORCE_HEADER] = nil
    message.perform_deliveries = forced || GeneralSetup.email_delivery?
  end
end
