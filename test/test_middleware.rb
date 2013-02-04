require_relative 'helper'

class TestMiddleware < Sidetiq::TestCase
  def middleware
    Sidetiq::Middleware.new
  end

  def test_restarts_clock
    clock.stubs(:ticking?).returns(false)
    clock.expects(:start!).once
    middleware.call {}

    clock.stubs(:ticking?).returns(true)
    clock.expects(:start!).never
    middleware.call {}
  end
end

