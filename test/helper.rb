if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start { add_filter "/test/" }
end

require 'minitest/autorun'
require 'mocha/setup'
require 'rack/test'

require 'sidekiq'
require 'sidekiq/testing'

require 'sidetiq'
require 'sidetiq/web'

# Keep the test output clean.
Sidekiq.logger = Logger.new(nil)

Dir[File.join(File.dirname(__FILE__), 'fixtures/**/*.rb')].each do |fixture|
  require fixture
end

class Sidetiq::TestCase < MiniTest::Unit::TestCase
  def setup
    Sidekiq.redis { |r| r.flushall }
  end

  def clock
    @clock ||= Sidetiq::Clock.instance
  end
end

