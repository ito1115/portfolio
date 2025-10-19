class BooksController < ApplicationController
  before_action :authenticate_user!

  # 手動で書籍を追加するフォーム
  def new
    @book = Book.new
  end

  # 手動で書籍を作成
  def create
    book_params = params.require(:book).permit(
      :title, :author, :publisher, :published_date,
      :description, :isbn, :image_url
    )

    # 既存の書籍をISBNまたはタイトル+著者で検索
    @book = if book_params[:isbn].present?
              Book.find_by(isbn: book_params[:isbn])
            else
              Book.find_by(title: book_params[:title], author: book_params[:author])
            end

    # 存在しなければ新規作成
    if @book.nil?
      @book = Book.new(book_params)
      if @book.save
        redirect_to new_reading_path(book_id: @book.id), notice: '書籍を追加しました'
      else
        render :new, status: :unprocessable_entity
      end
    else
      # 既に存在する場合もそのまま読書記録作成へ
      redirect_to new_reading_path(book_id: @book.id), notice: 'この書籍は既に登録されています'
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

  # Google Books APIの結果から書籍をDBに保存
  def create_from_google_books
    book_params = params.require(:book).permit(
      :title, :author, :publisher, :published_date,
      :description, :isbn, :image_url
    )

    # 既存の書籍をISBNまたはタイトル+著者で検索
    @book = if book_params[:isbn].present?
              Book.find_by(isbn: book_params[:isbn])
            else
              Book.find_by(title: book_params[:title], author: book_params[:author])
            end

    # 存在しなければ新規作成
    @book ||= Book.create(book_params)

    if @book.persisted?
      # 書籍保存後、読書記録作成画面へリダイレクト
      redirect_to new_reading_path(book_id: @book.id), notice: '書籍を選択しました'
    else
      redirect_to search_books_path, alert: '書籍の保存に失敗しました'
    end
  end
end