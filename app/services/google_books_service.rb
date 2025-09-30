require 'net/http'
require 'json'

class GoogleBooksService
  BASE_URL = 'https://www.googleapis.com/books/v1/volumes'

  # 本を検索するメソッド
  # @param query [String] 検索キーワード（タイトル、著者名など）
  # @param max_results [Integer] 取得する最大件数（デフォルト10件）
  # @return [Array<Hash>] 本の情報の配列
  def self.search(query, max_results: 10)
    return [] if query.blank?

    # APIのURLを構築
    uri = URI(BASE_URL)
    params = {
      q: query,                # 検索キーワード
      maxResults: max_results, # 取得件数
      langRestrict: 'ja'       # 日本語の本に限定
    }
    uri.query = URI.encode_www_form(params)

    begin
      # HTTPリクエストを送信
      response = Net::HTTP.get_response(uri)
      return [] unless response.is_a?(Net::HTTPSuccess)

      # JSONをパースして配列に変換
      data = JSON.parse(response.body)
      parse_books(data)
    rescue StandardError => e
      # エラーが発生した場合はログに記録して空配列を返す
      Rails.logger.error("Google Books API Error: #{e.message}")
      []
    end
  end

  # 特定の本をGoogle Books IDで取得
  # @param volume_id [String] Google Booksのvolume ID
  # @return [Hash, nil] 本の情報、または見つからない場合はnil
  def self.find_by_id(volume_id)
    return nil if volume_id.blank?

    uri = URI("#{BASE_URL}/#{volume_id}")

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

  private

  # 複数の本のデータを解析
  def self.parse_books(data)
    return [] unless data['items'].present?

    data['items'].map { |item| parse_book(item) }.compact
  end

  # 1冊の本のデータを解析してハッシュに変換
  # Google Books APIのレスポンスから必要な情報を抽出
  def self.parse_book(item)
    volume_info = item['volumeInfo']
    return nil unless volume_info.present?

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
    return nil unless identifiers.present?

    isbn_13 = identifiers.find { |id| id['type'] == 'ISBN_13' }
    return isbn_13['identifier'] if isbn_13

    isbn_10 = identifiers.find { |id| id['type'] == 'ISBN_10' }
    isbn_10&.dig('identifier')
  end
end