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
        info "Sidetiq v#{VERSION::STRING} - Copyright (c) 2012-2013, Tobias Svensson <tob@tobiassvensson.co.uk>"
        info "Sidetiq is covered by the 3-clause BSD license."
        info "See LICENSE and http://opensource.org/licenses/BSD-3-Clause for licensing details."
      end
    end
  end
end

