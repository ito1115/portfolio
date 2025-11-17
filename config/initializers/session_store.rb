# frozen_string_literal: true

# セッションストアの設定
Rails.application.config.session_store :cookie_store,
                                       key: '_graduation_app_session',
                                       secure: Rails.env.production?,
                                       same_site: :lax
