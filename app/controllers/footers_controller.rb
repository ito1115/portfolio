# frozen_string_literal: true

require 'net/http'
require 'uri'

class FootersController < ApplicationController
  def contact_form; end

  def terms; end

  def privacy; end

  def create
    uri = URI.parse('https://docs.google.com/forms/u/0/d/e/1FAIpQLScSJCWslQjiuAfO-rmsmlk6v2LW-rfHwXV5nFT6HUdoN1jTcQ/formResponse')

    # Googleフォームの各エントリIDに合わせてフォーム値をセット
    form_data = {
      'entry.198939506' => params[:name], # お名前
      'entry.1985865935' => params[:email], # メールアドレス
      'entry.318554638' => params[:content] # お問合せ内容
    }

    Net::HTTP.post_form(uri, form_data)

    flash[:notice] = t('flash.footers.contact_form.success')
    redirect_to root_path
  end
end
