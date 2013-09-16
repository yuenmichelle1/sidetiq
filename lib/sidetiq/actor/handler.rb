module Sidetiq
  module Actor
    class Handler < Sidetiq::Handler
      include Celluloid

      def initialize
        debug "Sidetiq::Handler initialize #{object_id}"
        super
      end
    end
  end
end
