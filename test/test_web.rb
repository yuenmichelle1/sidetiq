require_relative 'helper'

class TestWeb < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  class Worker
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    tiq do
      daily(1)
      yearly(2)
      monthly(3)

      add_exception_rule yearly.month_of_year(:february)
    end
  end

  def app
    Sidekiq::Web
  end

  def clock
    Sidetiq::Clock.instance
  end

  def test_home_tab
    get '/'
    assert_equal 200, last_response.status
    assert_match last_response.body, /Sidekiq/
    assert_match last_response.body, /Sidetiq/
  end

  def test_sidetiq_page
    get '/sidetiq'
    assert_equal 200, last_response.status

    clock.schedules.each do |worker, schedule|
      assert_match last_response.body, /#{worker.name}/
      assert_match last_response.body, /#{worker.get_sidekiq_options['queue']}/
    end
  end

  def test_details_page
    get "/sidetiq/#{Worker.name}"
    assert_equal 200, last_response.status
    schedule = clock.schedules[Worker]

    schedule.recurrence_rules.each do |rule|
      assert_match last_response.body, /#{rule.to_s}/
    end

    schedule.exception_rules.each do |rule|
      assert_match last_response.body, /#{rule.to_s}/
    end

    schedule.next_occurrences(10).each do |time|
      assert_match last_response.body, /#{time.getutc.to_s}/
    end
  end
end

