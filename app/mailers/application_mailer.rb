# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('GMAIL_USERNAME', 'noreply@tsundoku.com')
  layout 'mailer'
end
