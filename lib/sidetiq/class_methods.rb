module Sidetiq
  module Schedulable
    module ClassMethods
      def tiq(&block)
        Sidetiq::Scheduler.instance.instance_eval(&block)
      end
    end

    def self.included(klass)
      klass.extend(Sidetiq::Schedulable::ClassMethods)
    end
  end
end

