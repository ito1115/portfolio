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
      click_button commit: 'commit'

      # readings_pathにリダイレクトされて、本が表示されている
      expect(current_path).to eq readings_path
      expect(page).to have_content 'ステータステスト本'
      expect(page).to have_content '積読'

      reading.reload
      expect(reading.tsundoku?).to be true
    end

    it 'tsundokuからcompletedに変更できること' do
      reading = create(:reading, :tsundoku, user: user, book: book)

      visit edit_reading_path(reading)

      select '積読卒業', from: 'reading[status]'
      click_button commit: 'commit'

      expect(current_path).to eq readings_path
      expect(page).to have_content 'ステータステスト本'
      expect(page).to have_content '積読卒業'

      reading.reload
      expect(reading.completed?).to be true
    end

    it 'wishからcompletedに直接変更できること' do
      reading = create(:reading, user: user, book: book, status: :wish)

      visit edit_reading_path(reading)

      select '積読卒業', from: 'reading[status]'
      click_button commit: 'commit'

      expect(current_path).to eq readings_path
      expect(page).to have_content 'ステータステスト本'
      expect(page).to have_content '積読卒業'

      reading.reload
      expect(reading.completed?).to be true
    end
  end

  describe 'ステータスフィルタリング', js: true do
    let!(:wish_reading) { create(:reading, user: user, book: create(:book, title: '気になる本'), status: :wish) }
    let!(:tsundoku_reading) { create(:reading, :tsundoku, user: user, book: create(:book, title: '積読本')) }
    let!(:completed_reading) { create(:reading, :completed, user: user, book: create(:book, title: '完読本')) }

    xit 'wish状態の本のみを表示できること' do
      visit readings_path

      click_button '気になる'

      # JavaScriptの実行を待つ
      sleep 0.5

      # 表示されている本を確認
      expect(page).to have_content '気になる本'

      # 非表示になっている本を確認 (display: none)
      expect(page).to have_selector('.reading-item[data-status="tsundoku"]', visible: false)
      expect(page).to have_selector('.reading-item[data-status="completed"]', visible: false)
    end

    xit 'tsundoku状態の本のみを表示できること' do
      visit readings_path

      click_button '積読', match: :first

      # JavaScriptの実行を待つ
      sleep 0.5

      # 表示されている本を確認
      expect(page).to have_content '積読本'

      # 非表示になっている本を確認 (display: none)
      expect(page).to have_selector('.reading-item[data-status="wish"]', visible: false)
      expect(page).to have_selector('.reading-item[data-status="completed"]', visible: false)
    end

    xit 'completed状態の本のみを表示できること' do
      visit readings_path

      click_button '積読卒業'

      # JavaScriptの実行を待つ
      sleep 0.5

      expect(page).not_to have_content '気になる本', visible: false
      expect(page).not_to have_content '積読本', visible: false
      expect(page).to have_content '完読本'
    end
  end
end
