# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# OGP画像をプリコンパイル対象に追加
Rails.application.config.assets.precompile += %w[ogp.jpg]
Rails.application.config.assets.precompile += %w[ogp/ogp_background.jpg]

# フォントファイルをプリコンパイル対象に追加
Rails.application.config.assets.paths << Rails.root.join('app/assets/fonts')
Rails.application.config.assets.precompile += %w[NotoSansJP-VariableFont_wght.ttf]
