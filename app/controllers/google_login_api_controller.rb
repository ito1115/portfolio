class GoogleLoginApiController < ApplicationController
  require 'googleauth/id_tokens/verifier'

  protect_from_forgery except: :callback
  before_action :verify_g_csrf_token

  def callback
    payload = Google::Auth::IDTokens.verify_oidc(params[:credential], aud: '768617481149-qg2cg3pct9nc332mf9gq9g16s028rui3.apps.googleusercontent.com')

    user = User.find_or_initialize_by(email: payload['email'])

    if user.new_record?
      # 新規ユーザーの場合、ランダムなパスワードを設定し、メール確認をスキップ
      user.password = Devise.friendly_token[0, 20]
      user.confirmed_at = Time.current  # メール確認をスキップ
      user.save!
    end

    # Deviseのsign_inメソッドを使用
    sign_in(user)

    redirect_to after_sign_in_path_for(user), notice: 'ログインしました'
  end

  private

  def verify_g_csrf_token
    if cookies["g_csrf_token"].blank? || params[:g_csrf_token].blank? || cookies["g_csrf_token"] != params[:g_csrf_token]
      redirect_to root_path, notice: '不正なアクセスです'
    end
  end
end
