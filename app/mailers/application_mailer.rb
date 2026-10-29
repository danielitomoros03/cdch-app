class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "CDCH-UCV <iniciativas.cdch.ucv@gmail.com>")
  layout "mailer"
end
