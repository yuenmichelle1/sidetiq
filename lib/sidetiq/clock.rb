module Sidetiq
  # Public: The Sidetiq clock.
  class Clock
    include Logging

    # Internal: Returns a hash of Sidetiq::Schedule instances.
    attr_reader :schedules

    def initialize # :nodoc:
      super
      @schedules = {}
    end

    # Public: Get the schedule for `worker`.
    #
    # worker - A Sidekiq::Worker class
    #
    # Examples
    #
    #   schedule_for(MyWorker)
    #   # => Sidetiq::Schedule
    #
    # Returns a Sidetiq::Schedule instances.
    def schedule_for(worker)
      schedules[worker] ||= Sidetiq::Schedule.new
    end

    # Public: Issue a single clock tick.
    #
    # Examples
    #
    #   tick
    #   # => Hash of Sidetiq::Schedule objects
    #
    # Returns a hash of Sidetiq::Schedule instances.
    def tick
      tick = gettime
      schedules.each do |worker, sched|
        Sidetiq.handler.dispatch(worker,sched, tick)
      end
    end

    # Public: Returns the current time used by the clock.
    #
    # Examples
    #
    #   gettime
    #   # => 2013-02-04 12:00:45 +0000
    #
    # Returns a Time instance.
    def gettime
      Sidetiq.config.utc ? Time.now.utc : Time.now
    end
  end
end

