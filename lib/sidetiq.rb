# stdlib
require 'ostruct'
require 'singleton'
require 'socket'

# gems
require 'ice_cube'
require 'sidekiq'
require 'celluloid'

# internal
require 'sidetiq/config'
require 'sidetiq/logging'
require 'sidetiq/api'
require 'sidetiq/clock'
require 'sidetiq/lock'
require 'sidetiq/schedule'
require 'sidetiq/schedulable'
require 'sidetiq/version'

# actor topology
require 'sidetiq/actor/clock'
require 'sidetiq/supervisor'

# The Sidetiq namespace.
module Sidetiq
  include Sidetiq::API

  # Expose all instance methods as singleton methods.
  extend self

  class << self
    # Public: Setter for the Sidetiq logger.
    attr_writer :logger
  end

  # Public: Reader for the Sidetiq logger.
  #
  # Defaults to `Sidekiq.logger`.
  def logger
    @logger ||= Sidekiq.logger
  end

  # Public: Returns the Sidetiq::Clock actor.
  def clock
    Sidetiq::Supervisor.clock
  end
end
