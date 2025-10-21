# frozen_string_literal: true

require 'net/http'
require 'json'

class GoogleBooksService
  BASE_URL = 'https://www.googleapis.com/books/v1/volumes'

  # 本を検索するメソッド（ページネーション対応）
  # @param query [String] 検索キーワード（タイトル、著者名など）
  # @param page [Integer] ページ番号（デフォルト1）
  # @param per_page [Integer] 1ページあたりの件数（デフォルト20）
  # @return [Hash] 検索結果とページネーション情報
  def self.search(query, page: 1, per_page: 20)
    return { results: [], total_items: 0, current_page: page, per_page: per_page, total_pages: 0 } if query.blank?

    # ページネーション計算
    start_index = (page - 1) * per_page
    current_max = [per_page, 40].min # Google Books APIの最大値は40

    # APIのURLを構築
    uri = URI(BASE_URL)
    params = {
      q: query,                # 検索キーワード
      maxResults: current_max, # 取得件数
      startIndex: start_index, # 開始位置
      langRestrict: 'ja'       # 日本語の本に限定
    }
    # APIキーがあれば追加
    params[:key] = ENV['GOOGLE_BOOKS_API_KEY'] if ENV['GOOGLE_BOOKS_API_KEY'].present?
    uri.query = URI.encode_www_form(params)

    begin
      # HTTPリクエストを送信
      response = Net::HTTP.get_response(uri)

      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        results = parse_books(data)
        total_items = data['totalItems'] || 0

        {
          results: results,
          total_items: total_items,
          current_page: page,
          per_page: per_page,
          total_pages: (total_items.to_f / per_page).ceil
        }
      else
        Rails.logger.error("Google Books API Error: #{response.code} - #{response.body}")
        { results: [], total_items: 0, current_page: page, per_page: per_page, total_pages: 0 }
      end
    rescue StandardError => e
      # エラーが発生した場合はログに記録して空のハッシュを返す
      Rails.logger.error("Google Books API Error: #{e.message}")
      { results: [], total_items: 0, current_page: page, per_page: per_page, total_pages: 0 }
    end
  end

  # 特定の本をGoogle Books IDで取得
  # @param volume_id [String] Google Booksのvolume ID
  # @return [Hash, nil] 本の情報、または見つからない場合はnil
  def self.find_by_id(volume_id)
    return nil if volume_id.blank?

    uri = URI("#{BASE_URL}/#{volume_id}")
    # APIキーがあればクエリパラメータに追加
    uri.query = URI.encode_www_form(key: ENV['GOOGLE_BOOKS_API_KEY']) if ENV['GOOGLE_BOOKS_API_KEY'].present?

    begin
      response = Net::HTTP.get_response(uri)
      return nil unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      parse_book(data)
    rescue StandardError => e
      Rails.logger.error("Google Books API Error: #{e.message}")
      nil
    end
  end

  # 複数の本のデータを解析
  def self.parse_books(data)
    return [] if data['items'].blank?

    data['items'].map { |item| parse_book(item) }.compact
  end

  # 1冊の本のデータを解析してハッシュに変換
  # Google Books APIのレスポンスから必要な情報を抽出
  def self.parse_book(item)
    volume_info = item['volumeInfo']
    return nil if volume_info.blank?

    {
      google_books_id: item['id'],                              # Google BooksのID
      title: volume_info['title'],                              # タイトル
      author: volume_info['authors']&.join(', '),               # 著者（複数の場合はカンマ区切り）
      publisher: volume_info['publisher'],                      # 出版社
      published_date: volume_info['publishedDate'],             # 出版日
      description: volume_info['description'],                  # 説明文
      isbn: extract_isbn(volume_info['industryIdentifiers']),   # ISBN
      image_url: volume_info.dig('imageLinks', 'thumbnail')     # サムネイル画像URL
    }
  end

  # ISBNを抽出（ISBN-13を優先、なければISBN-10）
  def self.extract_isbn(identifiers)
    return nil if identifiers.blank?

    isbn13 = identifiers.find { |id| id['type'] == 'ISBN_13' }
    return isbn13['identifier'] if isbn13

    isbn10 = identifiers.find { |id| id['type'] == 'ISBN_10' }
    isbn10&.dig('identifier')
  end
end
