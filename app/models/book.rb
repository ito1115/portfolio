# frozen_string_literal: true

class Book < ApplicationRecord
  has_many :readings, dependent: :destroy

  validates :title, presence: true

  # 画像URLを取得する際、HTTPをHTTPSに変換（Mixed Content対策）
  def image_url
    url = read_attribute(:image_url)
    url&.sub(/^http:/, 'https:')
  end
end
