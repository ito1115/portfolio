# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '読書状態管理', type: :system do
  let(:user) { create(:user) }
  let(:book) { create(:book, title: 'ステータステスト本') }

  before do
    login_as user, scope: :user
  end

  describe 'ステータス変更' do
    it 'wishからtsundokuに変更できること' do
      reading = create(:reading, user: user, book: book, status: :wish)

      visit edit_reading_path(reading)

      select '積読', from: 'reading[status]'
      find('input[type="submit"]').click

      # readings_pathにリダイレクトされて、本が表示されている
      expect(page).to have_current_path(readings_path, wait: 5)
      expect(page).to have_content 'ステータステスト本'
      expect(page).to have_content '積読'

      reading.reload
      expect(reading.tsundoku?).to be true
    end

    it 'tsundokuからcompletedに変更できること' do
      reading = create(:reading, :tsundoku, user: user, book: book)

      visit edit_reading_path(reading)

      select '積読卒業', from: 'reading[status]'
      find('input[type="submit"]').click

      # リダイレクト完了を待つ
      expect(page).to have_current_path(readings_path, wait: 5)
      expect(page).to have_content 'ステータステスト本'
      expect(page).to have_content '積読卒業'

      reading.reload
      expect(reading.completed?).to be true
    end

    it 'wishからcompletedに直接変更できること' do
      reading = create(:reading, user: user, book: book, status: :wish)

      visit edit_reading_path(reading)

      select '積読卒業', from: 'reading[status]'
      find('input[type="submit"]').click

      # リダイレクト完了を待つ
      expect(page).to have_current_path(readings_path, wait: 5)
      expect(page).to have_content 'ステータステスト本'
      expect(page).to have_content '積読卒業'

      reading.reload
      expect(reading.completed?).to be true
    end
  end
end
