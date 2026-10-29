ActiveSupport.on_load(:action_mailer) { register_interceptor "MailDeliveryGate" }
