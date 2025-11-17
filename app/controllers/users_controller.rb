# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:profile]

  def registration_complete
    # メール送信完了画面
  end

  def profile
    @user = current_user
  end
end
