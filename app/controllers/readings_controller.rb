class ReadingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reading, only: [:show, :edit, :update, :destroy]

  def index
    @readings = current_user.readings.includes(:book).order(created_at: :desc)
  end

  def show
  end

  def new
    @reading = current_user.readings.build
    # 書籍検索から遷移してきた場合
    if params[:book_id].present?
      @reading.book_id = params[:book_id]
      @selected_book = Book.find_by(id: params[:book_id])
    end
  end

  def create
    @reading = current_user.readings.build(reading_params)

    if @reading.save
      redirect_to @reading, notice: '作成しました'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @reading.update(reading_params)
      # 読書状態が変更された場合
      if params[:reading][:status].present?
        status_name = @reading.status.humanize
        redirect_to readings_path, notice: "読書状態を「#{status_name}」に変更しました"
      else
        redirect_to @reading, notice: '更新しました'
      end
    else
      if params[:reading][:status].present?
        redirect_to readings_path, alert: '読書状態の変更に失敗しました。'
      else
        render :edit
      end
    end
  end

  def destroy
    @reading.destroy
    redirect_to readings_url, notice: '削除しました'
  end

  private

  def set_reading
    @reading = current_user.readings.find(params[:id])
  end

  def reading_params
    params.require(:reading).permit(:book_id, :reason, :status, :tsundoku_date,
                                      :wish_date, :completed_date)
  end
end