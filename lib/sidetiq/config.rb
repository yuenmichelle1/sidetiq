module Sidetiq
  class << self
    attr_writer :config

    def configure
      yield config
    end

    def config
      @config ||= OpenStruct.new
    end
  end
end

