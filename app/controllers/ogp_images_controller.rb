# frozen_string_literal: true

# OGP画像を動的に生成・配信するコントローラー
class OgpImagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    reading = Reading.find(params[:id])

    # OGP画像を生成
    generator = OgpImageGenerator.new(reading)
    tempfile = generator.generate

    # 画像を配信
    send_file tempfile.path,
              type: 'image/jpeg',
              disposition: 'inline',
              filename: "reading_#{reading.id}_ogp.jpg"
  rescue ActiveRecord::RecordNotFound
    # 見つからない場合は静的OGP画像を返す
    send_file Rails.root.join('app/assets/images/ogp.jpg'),
              type: 'image/jpeg',
              disposition: 'inline'
  rescue StandardError => e
    Rails.logger.error "OGP画像生成エラー: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    # エラー時は静的OGP画像を返す
    send_file Rails.root.join('app/assets/images/ogp.jpg'),
              type: 'image/jpeg',
              disposition: 'inline'
  end
end
