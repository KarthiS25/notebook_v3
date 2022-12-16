# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!
ActionMailer::Base.smtp_settings = {
    user_name: 'apikey',
    password: Rails.application.credentials.dig(:sendgrid_api_key),
    domain: 'nb-rails.fly.dev',
    address: 'smtp.sendgrid.net',
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true
  }