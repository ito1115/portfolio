# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    # ログイン済みの場合は読書記録一覧ページにリダイレクトすると、ログインユーザーがTOPページを見れないため一旦コメントアウト
    # redirect_to readings_path if user_signed_in?
  end
end
