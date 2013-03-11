# stdlib
require 'monitor'
require 'ostruct'
require 'singleton'

# gems
require 'ice_cube'
require 'sidekiq'

# c extensions
require 'sidetiq_ext'

# internal
require 'sidetiq/config'
require 'sidetiq/clock'
require 'sidetiq/middleware'
require 'sidetiq/schedule'
require 'sidetiq/schedulable'
require 'sidetiq/version'

# The Sidetiq namespace.
module Sidetiq
  # Public: Returns a Hash of Sidetiq::Schedule instances.
  def self.schedules
    Clock.synchronize do
      Clock.schedules.dup
    end
  end
end

