# frozen_string_literal: true

class DeviseMailer < ApplicationMailer
  default template_path: 'devise/mailer'

  # 既に登録済みのメールアドレスで登録を試みた場合の通知
  def already_registered(email)
    @email = email
    mail(to: email, subject: t('mailer.devise_mailer.already_registered.subject'))
  end
end
