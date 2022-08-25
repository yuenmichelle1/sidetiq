require 'sidekiq/exception_handler'

module Sidetiq
  class Handler
    include Logging
    include Sidekiq::ExceptionHandler

    def dispatch(worker, tick)
      schedule = worker.schedule
      return unless schedule.schedule_next?(tick)
      debug "Handler After Schedule.next"
      Lock::Redis.new(worker).synchronize do |redis|
        debug "Redis IN DISPATCH IN HANDLER #{redis}"
        if schedule.backfill? && (last = worker.last_scheduled_occurrence) > 0
          debug "Handler in backfill conditional"
          last = Sidetiq.config.utc ? Time.at(last).utc : Time.at(last)
          schedule.occurrences_between(last + 1, tick).each do |past_t|
            enqueue(worker, past_t, redis)
          end
        end
        debug "Handler Before WORKER ENQUEUE"
        enqueue(worker, schedule.next_occurrence(tick), redis)
      end
    rescue StandardError => e
      debug "Error in Handler #{e}"
      handle_exception(e, context: "Sidetiq::Handler#dispatch")
      raise e
    end

    private

    def enqueue(worker, time, redis)
      key      = "sidetiq:#{worker.name}"
      time_f   = time.to_f
      next_run = (redis.get("#{key}:next") || -1).to_f

      debug "INSIDE ENQUEUE WITHIN HANDLER"

      if next_run < time_f
        info "Enqueue: #{worker.name} (at: #{time_f}) (last: #{next_run})"

        redis.mset("#{key}:last", next_run, "#{key}:next", time_f)

        case worker.instance_method(:perform).arity.abs
        when 0
          worker.perform_at(time)
        when 1
          worker.perform_at(time, next_run)
        else
          worker.perform_at(time, next_run, time_f)
        end
      end
    rescue StandardError => e
      handle_exception(e, context: "Sidetiq::Handler#enqueue")
      raise e
    end
  end
end
