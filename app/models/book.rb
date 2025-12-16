# frozen_string_literal: true

class Book < ApplicationRecord
  has_many :readings, dependent: :destroy

  validates :title, presence: true
  validates :isbn, uniqueness: true, allow_nil: true

  # ISBNが空文字列の場合、nilに変換
  before_validation :normalize_isbn

  # 画像URLを取得する際、HTTPをHTTPSに変換（Mixed Content対策）
  def image_url
    url = read_attribute(:image_url)
    url&.sub(/^http:/, 'https:')
  end

  private

  def normalize_isbn
    self.isbn = nil if isbn.blank?
  end
end
