module Sidetiq
  # Public: Mixin for Sidekiq::Worker classes.
  #
  # Examples
  #
  #   class MyWorker
  #     include Sidekiq::Worker
  #     include Sidetiq::Schedulable
  #
  #     # Daily at midnight
  #     recurrence { daily }
  #   end
  module Schedulable
    extend SubclassTracking

    module ClassMethods
      include SubclassTracking

      attr_writer :schedule

      # Public: Returns a Float timestamp of the last scheduled run.
      def last_scheduled_occurrence
        get_timestamp "last"
      end

      # Public: Returns the Sidetiq::Schedule for this worker.
      def schedule
        @schedule ||= Sidetiq::Schedule.new
      end

      # Public: Returns a Float timestamp of the next scheduled run.
      def next_scheduled_occurrence
        get_timestamp "next"
      end

      def schedule_description
        get_schedulable_key("schedule_description")
      end

      def recurrence(options = {}, &block) # :nodoc:
        schedule.instance_eval(&block)
        schedule.set_options(options)

        # deleting schedulable keys if schedule changed since last reccurence definition
        old_description = get_schedulable_key("schedule_description")
        if old_description != schedule.to_s
          get_schedulable_keys.map do |key|
            schedulable_redis.del(key)
          end
          set_schedulable_key("schedule_description", schedule.to_s)
        end
      end

      private

      def schedulable_redis
        Sidekiq.redis { |redis| redis }
      end

      def get_schedulable_keys
        schedulable_redis.keys("sidetiq:#{name}:*")
      end

      def get_schedulable_key(key)
        schedulable_redis.get("sidetiq:#{name}:#{key}")
      end

      def set_schedulable_key(key, value)
        schedulable_redis.set("sidetiq:#{name}:#{key}", value)
      end

      def get_timestamp(key)
        (get_schedulable_key(key) || -1).to_f
      end
    end

    def self.included(klass) # :nodoc:
      super

      klass.extend(Sidetiq::Schedulable::ClassMethods)
      klass.extend(Sidetiq::SubclassTracking)
      subclasses << klass
    end
  end
end

