# Run with `sidekiq -r /path/to/simple.rb`

require 'sidekiq'
require 'sidetiq'
require_relative 'workers/simple'

Sidekiq.logger.level = Logger::DEBUG

Sidekiq.options[:poll_interval] = 1

Sidekiq.configure_server do |config|
  Sidetiq.clock.start!
end

