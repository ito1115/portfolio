# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@tsundoku.com'
  layout 'mailer'
end
