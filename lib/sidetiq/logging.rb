module Sidetiq
  # Public: Sidetiq logging interface.
  module Logging
    # Public: Setter for the Sidetiq logger.
    attr_writer :logger

    # Public: Reader for the Sidetiq logger.
    #
    # Defaults to `Sidekiq.logger`.
    def logger
      @logger ||= Sidekiq.logger
    end
  end
end
