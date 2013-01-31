require 'sidetiq'

# We're only loading this so we don't actually have to connect to redis.
require 'sidekiq/testing'

class ExampleWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  def self.perform_at(time)
    puts "Enqueued to run at #{time}"
  end

  # Run every 2 seconds
  tiq { secondly(2) }
end

puts "Hit C-c to quit."
sleep 1000000
