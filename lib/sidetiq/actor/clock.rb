module Sidetiq
  module Actor
    class Clock < Sidetiq::Clock
      include Sidetiq::Actor
      include Sidekiq::ExceptionHandler

      # Public: Starts the clock loop.
      def start!
        debug "Sidetiq::Clock looping ..."
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
