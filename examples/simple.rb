# Run with `sidekiq -r /path/to/simple.rb`

require 'sidekiq'
require 'sidetiq'

Sidekiq.options[:poll_interval] = 1

class MyWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  tiq { secondly }

  def perform(*args)
    Sidekiq.logger.info "#perform"
  end
end

