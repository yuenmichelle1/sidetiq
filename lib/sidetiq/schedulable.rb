module Sidetiq
  # Public: Mixin for Sidekiq::Worker classes.
  #
  # Examples
  #
  #   class MyWorker
  #       include Sidekiq::Worker
  #       include Sidetiq::Schedulable
  #
  #       # Daily at midnight
  #       tiq { daily }
  #     end
  module Schedulable
    module ClassMethods
      def tiq(&block) # :nodoc:
        clock = Sidetiq::Clock.instance
        clock.synchronize do
          clock.schedule_for(self).instance_eval(&block)
        end
      end
    end

    def self.included(klass) # :nodoc:
      klass.extend(Sidetiq::Schedulable::ClassMethods)
    end
  end
end

