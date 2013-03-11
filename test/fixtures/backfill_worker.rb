class BackfillWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  tiq backfill: true do
    daily
  end

  def perform
  end
end
