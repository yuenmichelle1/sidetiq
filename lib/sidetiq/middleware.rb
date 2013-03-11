module Sidetiq
  class Middleware
    def initialize
      @clock = Sidetiq::Clock.instance
    end

    def call(*args)
      # Restart the clock if the thread died.
      if !@clock.ticking?
        Sidetiq.logger.warn "Sidetiq::Clock thread died. Restarting..."
        @clock.start!
      end
      yield
    end
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidetiq::Middleware
  end
end

