module Sidetiq
  module Schedulable
    module ClassMethods
      def tiq(&block)
        clock = Sidetiq::Clock.instance
        clock.synchronize do
          clock.schedule_for(self).instance_eval(&block)
        end
      end
    end

    def self.included(klass)
      klass.extend(Sidetiq::Schedulable::ClassMethods)
    end
  end
end

