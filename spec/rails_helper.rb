# frozen_string_literal: true

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'shoulda/matchers'
require 'capybara/rspec'
require 'database_cleaner/active_record'

# spec/supportディレクトリ内のファイルを読み込む
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# テストデータベースのスキーマを最新に保つ
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # FactoryBotのメソッドを直接使えるようにする
  config.include FactoryBot::Syntax::Methods

  config.fixture_paths = [Rails.root.join('spec/fixtures')]

  # DatabaseCleanerを使用するため、use_transactional_fixturesはfalseに設定
  config.use_transactional_fixtures = false

  # DatabaseCleanerの設定（JavaScriptテストおよびシステムテスト）
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |example|
    # システムテストまたはJavaScriptテストの場合はtruncationを使用
    DatabaseCleaner.strategy = if example.metadata[:type] == :system || example.metadata[:js]
                                 :truncation
                               else
                                 :transaction
                               end
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # バックトレースからRails gemの行をフィルタリング
  config.filter_rails_from_backtrace!

  # Capybara設定
  Capybara.default_max_wait_time = 5

  # webdriver設定(capybara)
  config.before(:each, type: :system) do
    if ENV['CI']
      # CI環境ではSelenium Serverを使わずにヘッドレスChromeを直接使用
      driven_by :selenium, using: :headless_chrome, screen_size: [1680, 1050] do |driver_options|
        driver_options.add_argument('--no-sandbox')
        driver_options.add_argument('--disable-dev-shm-usage')
        driver_options.add_argument('--disable-gpu')
        # JavaScriptのconfirmダイアログを有効化（デフォルトで動作するはず）
        driver_options.add_argument('--enable-features=NetworkService,NetworkServiceInProcess')
      end
    else
      # ローカル環境ではremote_chromeを使用
      driven_by :remote_chrome
      Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
      Capybara.server_port = 4444
      Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"
    end
    Capybara.ignore_hidden_elements = false
  end
end

# Shoulda Matchers設定
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
