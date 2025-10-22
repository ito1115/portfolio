# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ユーザー認証', type: :system do
  describe 'ユーザー登録' do
    it '有効な情報でユーザー登録ができること' do
      visit new_user_registration_path

      fill_in 'Email', with: 'test@example.com'
      fill_in 'Password', with: 'password123'
      fill_in 'Password confirmation', with: 'password123'
      click_button 'Sign up'

      # ログイン後のページにリダイレクトされる(root_path)
      expect(current_path).to eq root_path
      expect(page).to have_content 'Welcome, test@example.com!'
    end

    it 'メールアドレスが空の場合、登録できないこと' do
      visit new_user_registration_path

      fill_in 'Email', with: ''
      fill_in 'Password', with: 'password123'
      fill_in 'Password confirmation', with: 'password123'
      click_button 'Sign up'

      expect(page).to have_content 'Emailを入力してください'
    end

    it 'パスワードが6文字未満の場合、登録できないこと' do
      visit new_user_registration_path

      fill_in 'Email', with: 'test@example.com'
      fill_in 'Password', with: '12345'
      fill_in 'Password confirmation', with: '12345'
      click_button 'Sign up'

      expect(page).to have_content 'Passwordは6文字以上で入力してください'
    end

    it 'パスワードと確認用パスワードが一致しない場合、登録できないこと' do
      visit new_user_registration_path

      fill_in 'Email', with: 'test@example.com'
      fill_in 'Password', with: 'password123'
      fill_in 'Password confirmation', with: 'different'
      click_button 'Sign up'

      expect(page).to have_content 'Passwordが一致しません'
    end
  end

  describe 'ログイン' do
    let!(:user) { create(:user, password: 'password123') }

    it '有効な情報でログインができること' do
      visit new_user_session_path

      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: 'password123'
      click_button commit: 'commit'

      # ログイン後のページにリダイレクトされる
      expect(current_path).to eq root_path
      expect(page).to have_content "Welcome, #{user.email}!"
    end

    it 'メールアドレスが間違っている場合、ログインできないこと' do
      visit new_user_session_path

      fill_in 'Email', with: 'wrong@example.com'
      fill_in 'Password', with: 'password123'
      click_button 'Log in'

      # ログインページに留まる
      expect(current_path).to eq new_user_session_path
      expect(page).to have_content 'Log in'
    end

    it 'パスワードが間違っている場合、ログインできないこと' do
      visit new_user_session_path

      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'wrongpassword'
      click_button 'Log in'

      # ログインページに留まる
      expect(current_path).to eq new_user_session_path
      expect(page).to have_content 'Log in'
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
