# frozen_string_literal: true

# Deviseヘルパーメソッドの設定
RSpec.configure do |config|
  # system specではWarden::Test::Helpersを使用
  config.include Warden::Test::Helpers, type: :system

  config.after(:each, type: :system) do
    Warden.test_reset!
  end
end
