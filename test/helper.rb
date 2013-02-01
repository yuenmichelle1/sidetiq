require 'simplecov'
SimpleCov.start { add_filter "/test/" }

require 'minitest/autorun'
require 'mocha/setup'
require 'rack/test'
require 'mock_redis'

require 'sidekiq'
require 'sidekiq/testing'

require 'sidetiq'
require 'sidetiq/web'

# Stub out Clock#start! so we don't actually loop
module Sidetiq
  class Clock
    def start!; end
  end
end

# Keep the test output clean
Sidekiq.logger = Logger.new(nil)

class Sidetiq::TestCase < MiniTest::Unit::TestCase
  def setup
    Sidekiq.redis { |r| r.flushall }
  end
end

