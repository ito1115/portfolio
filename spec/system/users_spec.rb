# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ユーザー認証', type: :system do
  describe 'ユーザー登録' do
    it '有効な情報でユーザー登録ができること' do
      visit new_user_registration_path

      fill_in 'メールアドレス', with: 'test@example.com'
      fill_in 'パスワード', with: 'password123', match: :prefer_exact
      fill_in 'パスワード確認', with: 'password123'
      click_button '新規登録'

      # 登録後は読書記録一覧ページにリダイレクトされる
      expect(current_path).to eq readings_path
    end

    it 'メールアドレスが空の場合、登録できないこと' do
      visit new_user_registration_path

      fill_in 'メールアドレス', with: ''
      fill_in 'パスワード', with: 'password123', match: :prefer_exact
      fill_in 'パスワード確認', with: 'password123'
      click_button '新規登録'

      # バリデーションエラーでページが再表示されるのを待つ
      expect(page).to have_content('メールアドレス を入力してください', wait: 5)
    end

    it 'パスワードが6文字未満の場合、登録できないこと' do
      visit new_user_registration_path

      fill_in 'メールアドレス', with: 'test@example.com'
      fill_in 'パスワード', with: '12345', match: :prefer_exact
      fill_in 'パスワード確認', with: '12345'
      click_button '新規登録'

      # バリデーションエラーでページが再表示されるのを待つ
      expect(page).to have_content('パスワード は6文字以上で入力してください', wait: 5)
    end

    it 'パスワードと確認用パスワードが一致しない場合、登録できないこと' do
      visit new_user_registration_path

      fill_in 'メールアドレス', with: 'test@example.com'
      fill_in 'パスワード', with: 'password123', match: :prefer_exact
      fill_in 'パスワード確認', with: 'different'
      click_button '新規登録'

      # バリデーションエラーでページが再表示されるのを待つ
      expect(page).to have_content('パスワード確認 が一致しません', wait: 5)
    end
  end

  describe 'ログイン' do
    let!(:user) { create(:user, password: 'password123') }

    it '有効な情報でログインができること' do
      visit new_user_session_path

      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: 'password123'
      click_button 'ログイン'

      # ログイン後は読書記録一覧ページにリダイレクトされる
      expect(current_path).to eq readings_path
    end

    it 'メールアドレスが間違っている場合、ログインできないこと' do
      visit new_user_session_path

      fill_in 'メールアドレス', with: 'wrong@example.com'
      fill_in 'パスワード', with: 'password123'
      click_button 'ログイン'

      # ログインページに留まる
      expect(current_path).to eq new_user_session_path
    end

    it 'パスワードが間違っている場合、ログインできないこと' do
      visit new_user_session_path

      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: 'wrongpassword'
      click_button 'ログイン'

      # ログインページに留まる
      expect(current_path).to eq new_user_session_path
    end
  end

  describe 'ログアウト' do
    let(:user) { create(:user) }

    before do
      login_as user, scope: :user
    end

    xit 'ログアウトができること' do
      # TODO: ログアウト機能が実装されたら有効化する
      visit root_path
      click_link 'Log out'

      expect(page).to have_content 'ログアウトしました。'
      expect(current_path).to eq root_path
    end
  end
end
