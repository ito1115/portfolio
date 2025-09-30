class BooksController < ApplicationController
  before_action :authenticate_user!

  # Google Books APIで書籍を検索
  def search
    @query = params[:query]
    @books = []

    if @query.present?
      @books = GoogleBooksService.search(@query)
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