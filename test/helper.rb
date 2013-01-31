require 'simplecov'
SimpleCov.start { add_filter "/test/" }
require 'minitest/autorun'
require 'mocha/setup'
require 'sidetiq'
require 'sidekiq/testing'

# Stub out Clock#start! so we don't actually loop
module Sidetiq
  class Clock
    def start!; end
  end
end

# Keep the test output clean
Sidekiq.logger = Logger.new(nil)
