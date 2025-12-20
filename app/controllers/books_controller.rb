# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]

  # 手動で書籍を追加するフォーム
  def new
    @book = Book.new
  end

  # 手動またはGoogle Books APIから書籍を作成
  def create
    book_params = params.expect(
      book: %i[title author publisher published_date
               description isbn image_url source]
    )
    source = book_params[:source] || 'manual'

    # 既存の書籍を検索、なければ新規インスタンスを作成
    @book = Book.find_or_initialize_from_params(book_params)

    if @book.persisted? || @book.save
      # 既存データ使用の場合も新規作成の場合と同じ成功メッセージ
      redirect_to new_reading_path(book_id: @book.id), notice: t('flash.books.create.success')
    elsif source == 'google_books'
      redirect_to search_books_path, alert: t('flash.books.create.failure')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Google Books APIで書籍を検索
  def search
    @query = params[:query]
    @page = params[:page]&.to_i || 1
    @per_page = 20

    if @query.present?
      result = GoogleBooksService.search(@query, page: @page, per_page: @per_page)
      @books = result[:results]
      @pagination_info = {
        total_items: result[:total_items],
        current_page: result[:current_page],
        per_page: result[:per_page],
        total_pages: result[:total_pages]
      }
    else
      @books = []
      @pagination_info = { total_items: 0, current_page: @page, per_page: @per_page, total_pages: 0 }
    end
  end

  # 検索候補を取得するAPI
  def suggestions
    # Stimulus Autocompleteは'q'パラメータを使う
    query = params[:q] || params[:query]

    if query.present?
      result = GoogleBooksService.search(query, page: 1, per_page: 3)
      @suggestions = result[:results].map do |book|
        {
          title: book[:title],
          author: book[:author],
          image_url: book[:image_url]
        }
      end
    else
      @suggestions = []
    end

    # HTML形式でレスポンスを返す
    render partial: 'books/suggestion_results', locals: { suggestions: @suggestions }
  end
end
