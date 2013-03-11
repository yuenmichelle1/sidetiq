require_relative 'helper'

class TestWeb < Sidetiq::TestCase
  include Rack::Test::Methods

  def app
    Sidekiq::Web
  end

  def host
    last_request.host
  end

  def setup
    super
    ScheduledWorker.jobs.clear
  end

  def test_home_tab
    get '/'
    assert_equal 200, last_response.status
    assert_match /Sidekiq/, last_response.body
    assert_match /Sidetiq/, last_response.body
  end

  def test_sidetiq_page
    get '/sidetiq'
    assert_equal 200, last_response.status

    clock.schedules.each do |worker, schedule|
      assert_match /#{worker.name}/, last_response.body
      assert_match /#{worker.get_sidekiq_options['queue']}/, last_response.body
    end
  end

  def test_details_page
    get "/sidetiq/ScheduledWorker"
    assert_equal 200, last_response.status
    schedule = clock.schedules[ScheduledWorker]

    schedule.recurrence_rules.each do |rule|
      assert_match /#{rule.to_s}/, last_response.body
    end

    schedule.exception_rules.each do |rule|
      assert_match /#{rule.to_s}/, last_response.body
    end

    schedule.next_occurrences(10).each do |time|
      assert_match /#{time.getutc.to_s}/, last_response.body
    end
  end

  def test_trigger
    post "/sidetiq/ScheduledWorker/trigger"
    assert_equal 302, last_response.status
    assert_equal "http://#{host}/sidetiq", last_response.location
    assert_equal 1, ScheduledWorker.jobs.size
  end
end

