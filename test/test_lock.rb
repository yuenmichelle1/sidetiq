require_relative 'helper'

class TestLock < Sidetiq::TestCase
  def test_locking
    lock_name = SecureRandom.hex(8)
    key = SecureRandom.hex(8)

    Sidekiq.redis do |redis|
      redis.set(key, 0)

      5.times.map do
        Thread.start do
          locked(lock_name) do |r|
            sleep 0.1
            r.incr(key)
          end
        end
      end.each(&:join)

      assert_equal "1", redis.get(key)
    end
  end

  def locked(lock_name)
    Sidetiq::Lock.new(lock_name).synchronize do |redis|
      yield redis
    end
  end
end

