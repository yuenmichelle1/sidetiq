module Sidetiq
  class Supervisor < Celluloid::SupervisionGroup
    supervise Sidetiq::Actor::Clock, as: :sidetiq_clock

    class << self
      include Logging

      def clock
        run! if Celluloid::Actor[:sidetiq_clock].nil?

        Celluloid::Actor[:sidetiq_clock]
      end

      def run!
        motd
        debug "Sidetiq::Supervisor start"

        super
      end

      def run
        motd
        debug "Sidetiq::Supervisor start (foreground)"

        super
      end

      private

      def motd
        info "Sidetiq v#{VERSION::STRING} booting ..."
      end
    end
  end
end

