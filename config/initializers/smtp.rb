if ENV["SMTP_HOST"].present?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.smtp_settings = {
    address: ENV.fetch("SMTP_HOST"),
    port: ENV.fetch("SMTP_PORT", 587).to_i,
    user_name: ENV["SMTP_USER"],
    password: ENV["SMTP_PASSWORD"],
    authentication: :plain,
    enable_starttls_auto: true
  }
elsif Rails.env.development?
  ActionMailer::Base.delivery_method = :file
end
