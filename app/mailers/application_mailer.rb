class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "ShiftDesk <from@example.com>")
  layout "mailer"
end
