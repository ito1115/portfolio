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

  # 既存の書籍を検索、なければ新規インスタンスを作成
  def self.find_or_initialize_from_params(book_params)
    book = if book_params[:isbn].present?
             find_by(isbn: book_params[:isbn])
           else
             find_by(title: book_params[:title], author: book_params[:author])
           end

    book || new(book_params.except(:source))
  end

  private

  def normalize_isbn
    self.isbn = nil if isbn.blank?
  end
end
