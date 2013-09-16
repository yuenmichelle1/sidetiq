# stdlib
require 'ostruct'
require 'singleton'
require 'socket'

# gems
require 'ice_cube'
require 'sidekiq'

# internal
require 'sidetiq/api'
require 'sidetiq/config'
require 'sidetiq/clock'
require 'sidetiq/lock'
require 'sidetiq/logging'
require 'sidetiq/middleware'
require 'sidetiq/schedule'
require 'sidetiq/schedulable'
require 'sidetiq/version'

# The Sidetiq namespace.
module Sidetiq
  include Sidetiq::API
  include Sidetiq::Logging

  # Expose all instance methods as singleton methods.
  extend self
end
