module Sidetiq
  configure do |config|
    config.priority = Thread.current.priority
    config.resolution = 0.2
  end

  class Clock
    include Singleton
    include MonitorMixin

    attr_reader :schedules

    def initialize
      super
      @schedules = {}
      start!
    end

    def schedule_for(worker)
      schedules[worker] ||= Sidetiq::Schedule.new
    end

    def tick
      @tick = gettime

      synchronize do
        schedules.each do |worker, schedule|
          if schedule.schedule_next?(@tick)
            occurrence = schedule.next_occurrence
            Sidekiq.logger.info "Sidetiq::Clock enqueue #{worker.name} (at: #{occurrence.to_s})"
            worker.perform_at(occurrence)
          end
        end
      end
    end

    private

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

