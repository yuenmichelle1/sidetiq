class ScheduledWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  tiq do
    daily(1)
    yearly(2)
    monthly(3)

    add_exception_rule yearly.month_of_year(:february)
  end
end

