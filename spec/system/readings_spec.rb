# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '積読本管理', type: :system do
  let(:user) { create(:user) }
  let(:book) { create(:book, title: 'テスト本') }

  before do
    login_as user, scope: :user
  end

  describe '積読本登録' do
    it '有効な情報で積読本を登録できること' do
      book # bookを事前に作成
      visit new_reading_path

      select book.title, from: 'reading[book_id]'
      fill_in 'reading[reason]', with: 'この本が面白そうだから'
      select '気になる', from: 'reading[status]'
      click_button 'Create Reading'

      # 作成後は詳細ページ(show)にリダイレクトされる
      expect(page).to have_content book.title
      expect(page).to have_content 'この本が面白そうだから'
      expect(page).to have_content '気になる'
    end

    it 'ステータスが必須であること' do
      book # bookを事前に作成
      visit new_reading_path

      select book.title, from: 'reading[book_id]'
      fill_in 'reading[reason]', with: 'この本が面白そうだから'

      # HTML5バリデーションを無効化してフォーム送信
      page.execute_script("document.querySelector('select[name=\"reading[status]\"]').removeAttribute('required')")

      click_button 'Create Reading'

      # バリデーションエラーメッセージを確認
      expect(page).to have_content 'Status を選択してください'
      # フォームが再表示されていることを確認
      expect(page).to have_button 'Create Reading'
    end
  end

  describe '積読本一覧' do
    let!(:wish_reading) { create(:reading, user: user, book: create(:book, title: '気になる本'), status: :wish) }
    let!(:tsundoku_reading) { create(:reading, :tsundoku, user: user, book: create(:book, title: '積読中の本')) }
    let!(:completed_reading) { create(:reading, :completed, user: user, book: create(:book, title: '読了した本')) }

    it '自分の積読本一覧が表示されること' do
      visit readings_path

      expect(page).to have_content '気になる本'
      expect(page).to have_content '積読中の本'
      expect(page).to have_content '読了した本'
    end

    it '他のユーザーの積読本は表示されないこと' do
      other_user = create(:user)
      create(:reading, user: other_user, book: create(:book, title: '他人の本'))

      visit readings_path

      expect(page).not_to have_content '他人の本'
    end
  end

  describe '積読本詳細' do
    let(:reading) { create(:reading, user: user, book: book, reason: '詳細テスト理由') }

    it '積読本の詳細が表示されること' do
      visit reading_path(reading)

      expect(page).to have_content book.title
      expect(page).to have_content '詳細テスト理由'
      expect(page).to have_content '気になる'
    end
  end

  describe '積読本編集' do
    let(:reading) { create(:reading, user: user, book: book, reason: '元の理由') }

    it '積読本の情報を編集できること' do
      visit edit_reading_path(reading)

      fill_in 'reading[reason]', with: '更新した理由'
      select '積読', from: 'reading[status]'
      find('input[type="submit"]').click

      # 更新後はreadings_pathにリダイレクトされる
      expect(page).to have_current_path(readings_path, wait: 5)
      expect(page).to have_content book.title
      expect(page).to have_content '積読'
    end
  end

  describe '積読本削除', js: true do
    let!(:reading) { create(:reading, user: user, book: book) }

    it '積読本を削除できること' do
      visit reading_path(reading)

      # 削除ボタンをクリックし、確認ダイアログを受け入れる
      accept_confirm do
        click_button '削除'
      end

      # 削除後はreadings_pathにリダイレクトされる
      expect(page).to have_current_path(readings_path, wait: 5)
      expect(page).not_to have_content book.title
    end
  end
end
