# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Deviseのログイン後・登録後のリダイレクト先をカスタマイズ
  def after_sign_in_path_for(_resource)
    readings_path
  end

  def after_sign_up_path_for(_resource)
    readings_path
  end
end
