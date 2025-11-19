# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    # before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    def create
      Rails.logger.info '=== RegistrationsController#create called ==='
      Rails.logger.info "Email: #{sign_up_params[:email]}"

      # メールアドレスが既に登録済みかチェック（User Enumeration対策）
      existing_user = User.find_by(email: sign_up_params[:email])

      if existing_user
        Rails.logger.info '=== Existing user found, sending email ==='
        # 既存ユーザーに通知メールを送信
        DeviseMailer.already_registered(existing_user.email).deliver_now
        Rails.logger.info '=== Email sent ==='
        # 成功画面に遷移（攻撃者が判別できないようにする）
        redirect_to users_registration_complete_path
      else
        Rails.logger.info '=== New user, calling super ==='
        # 通常の登録処理
        super
      end
    end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_up_params
    #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
    # end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    # end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts (confirmableが有効な場合).
    def after_inactive_sign_up_path_for(_resource)
      users_registration_complete_path
    end

    # The path used after updating account information.
    def after_update_path_for(_resource)
      profile_path
    end
  end
end
