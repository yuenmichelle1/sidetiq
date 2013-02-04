module Sidetiq
  class << self
    # Public: Sets the configuration used by Sidetiq.
    attr_writer :config

    # Public: Configuration wrapper for block configurations.
    #
    # Examples
    #
    #   Sidetiq.configure do |config|
    #     config.resolution = 0.2
    #   end
    #
    # Yields the configuration OpenStruct currently set.
    # Returns nothing.
    def configure
      yield config
    end

    # Public: Returns the current configuration used by Sidetiq.
    def config
      @config ||= OpenStruct.new
    end
  end
end

