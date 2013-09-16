class Simple
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { secondly }

  def perform(*args)
    Sidekiq.logger.info "#perform"
  end
end

