# frozen_string_literal: true

class ReadingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reading, only: %i[show edit update destroy]

  def index
    @readings = current_user.readings.includes(:book, :purchase_medium).order(created_at: :desc)
  end

  def show; end

  def new
    @reading = current_user.readings.build
    @purchase_media = PurchaseMedium.order(:id)
    # 書籍検索から遷移してきた場合
    return if params[:book_id].blank?

    @reading.book_id = params[:book_id]
    @selected_book = Book.find_by(id: params[:book_id])
  end

  def edit
    @purchase_media = PurchaseMedium.order(:id)
  end

  def create
    @reading = current_user.readings.build(reading_params)

    if @reading.save
      redirect_to @reading, notice: t('flash.readings.create.success')
    else
      render :new
    end
  end

  def update
    if @reading.update(reading_params)
      # 読書状態が変更された場合
      if params[:reading][:status].present?
        status_name = @reading.status.humanize
        redirect_to readings_path, notice: "読書状態を「#{status_name}」に変更しました"
      else
        redirect_to @reading, notice: t('flash.readings.update.success')
      end
    elsif params[:reading][:status].present?
      redirect_to readings_path, alert: t('flash.readings.update.failure')
    else
      render :edit
    end
  end

  def destroy
    @reading.destroy
    redirect_to readings_url, notice: t('flash.readings.destroy.success')
  end

  def recommend
    @reading = current_user.readings.includes(:book).order('RANDOM()').first
  end

  # AI購入理由推測API
  def predict_reason
    predicted_reason = ReasonPredictor.predict(
      user: current_user,
      book_title: params[:title],
      book_author: params[:author],
      book_description: params[:description]
    )

    if predicted_reason.present?
      render json: { success: true, reason: predicted_reason }
    else
      render json: { success: false, error: 'AI推測に失敗しました' }, status: :unprocessable_entity
    end
  end

  private

  def set_reading
    @reading = current_user.readings.find(params[:id])
  end

  def reading_params
    params.expect(reading: %i[book_id reason status tsundoku_date
                              wish_date completed_date purchase_medium_id])
  end
end
