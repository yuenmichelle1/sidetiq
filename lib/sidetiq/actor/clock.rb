module Sidetiq
  module Actor
    class Clock < Sidetiq::Clock
      include Celluloid
      include Sidekiq::ExceptionHandler

      # Public: Starts and supervises the clock actor.
      def self.start!
        actor.start!
      end

      # Public: Starts the clock loop.
      def start!
        debug "Sidetiq::Clock start"
        loop!
      end

      private

      def loop!
        after([time { tick }, 0].max) do
          loop!
        end
      rescue StandardError => e
        handle_exception(e, context: 'Sidetiq::Clock#loop!')
        retry
      end

      def time
        start = gettime
        yield
        Sidetiq.config.resolution - (gettime.to_f - start.to_f)
      end
    end
  end
end
