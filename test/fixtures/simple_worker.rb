class SimpleWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  def perform
  end
end

