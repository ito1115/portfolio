# frozen_string_literal: true

require 'selenium/webdriver'

Capybara.register_driver :remote_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  # 基本設定
  options.add_argument('no-sandbox')
  options.add_argument('headless')
  options.add_argument('disable-gpu')
  options.add_argument('window-size=1680,1050')

  # パフォーマンス改善
  options.add_argument('disable-dev-shm-usage') # メモリ使用量削減
  options.add_argument('disable-setuid-sandbox')
  options.add_argument('disable-extensions')
  options.add_argument('disable-infobars')

  # 画像読み込みを無効化（テスト高速化）
  options.add_preference('profile.default_content_setting_values.images', 2)
  options.add_preference('profile.managed_default_content_settings.images', 2)

  Capybara::Selenium::Driver.new(app, browser: :remote, url: ENV.fetch('SELENIUM_DRIVER_URL', nil),
                                      capabilities: options)
end
