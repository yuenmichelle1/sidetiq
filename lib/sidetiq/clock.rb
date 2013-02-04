module Sidetiq
  configure do |config|
    config.priority = Thread.main.priority
    config.resolution = 1
    config.lock_expire = 1000
    config.utc = false
  end

  class Clock
    include Singleton
    include MonitorMixin

    START_TIME = Sidetiq.config.utc ? Time.utc(2010, 1, 1) : Time.local(2010, 1, 1)

    attr_reader :schedules

    def self.method_missing(meth, *args, &block)
      instance.__send__(meth, *args, &block)
    end

    def initialize
      super
      @schedules = {}
      start!
    end

    def schedule_for(worker)
      schedules[worker] ||= Sidetiq::Schedule.new(START_TIME)
    end

    def tick
      @tick = gettime
      synchronize do
        schedules.each do |worker, schedule|
          if schedule.schedule_next?(@tick)
            enqueue(worker, schedule.next_occurrence(@tick))
          end
        end
      end
    end

    def gettime
      Sidetiq.config.utc ? clock_gettime.utc : clock_gettime
    end

    private

    def enqueue(worker, time)
      key = "sidetiq:#{worker.name}"

      synchronize_clockworks("#{key}:lock") do |redis|
        status = redis.get(key)

        if status.nil? || status.to_f < time.to_f
          time_f = time.to_f
          Sidekiq.logger.info "Sidetiq::Clock enqueue #{worker.name} (at: #{time_f})"
          redis.set(key, time_f)
          worker.perform_at(time)
        end
      end
    end

    def synchronize_clockworks(lock)
      Sidekiq.redis do |redis|
        if redis.setnx(lock, 1)
          Sidekiq.logger.debug "Sidetiq::Clock lock #{lock} #{Thread.current.inspect}"

          redis.pexpire(lock, Sidetiq.config.lock_expire)
          yield redis
          redis.del(lock)

          Sidekiq.logger.debug "Sidetiq::Clock unlock #{lock} #{Thread.current.inspect}"
        end
      end
    end

    def start!
      Sidekiq.logger.info "Sidetiq::Clock start"
      thr = Thread.start { clock { tick } }
      thr.abort_on_exception = true
      thr.priority = Sidetiq.config.resolution
    end

    def clock
      loop do
        yield
        Thread.pass
        sleep Sidetiq.config.resolution
      end
    end
  end
end

