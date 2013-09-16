# Run with `sidekiq -r /path/to/simple.rb`

require 'sidekiq'
require 'sidetiq'

Sidekiq.logger.level = Logger::DEBUG

Sidekiq.options[:poll_interval] = 1

Sidekiq.configure_server do |config|
  Sidetiq.clock.start!
end

class MyWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { secondly }

  def perform(*args)
    Sidekiq.logger.info "#perform"
  end
end

