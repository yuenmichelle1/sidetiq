module Sidetiq
  module Actor
    def self.included(base)
      base.__send__(:include, Celluloid)
    end

    def initialize(*args, &block)
      log_call "initialize"
      super
    end

    private

    def log_call(call)
      info "#{self.class.name} id: #{object_id} #{call}"
    end
  end
end
