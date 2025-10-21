# frozen_string_literal: true

require 'openai'

OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_API_KEY', nil)
  config.log_errors = true
end
