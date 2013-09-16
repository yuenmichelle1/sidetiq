require 'sidekiq/web'

module Sidetiq
  module Web
    VIEWS = File.expand_path('views', File.dirname(__FILE__))

    def self.registered(app)
      app.get "/sidetiq" do
        @schedules = Sidetiq.schedules
        @time = Sidetiq.clock.gettime
        erb File.read(File.join(VIEWS, 'sidetiq.erb'))
      end

      app.get "/sidetiq/locks" do
        Sidekiq.redis do |redis|
          lock_keys = redis.keys('sidetiq:*:lock')

          @locks = (lock_keys.any? ? redis.mget(*lock_keys) : []).map do |lock|
            Sidetiq::Lock::MetaData.from_json(lock)
          end
        end

        erb File.read(File.join(VIEWS, 'sidetiq_locks.erb'))
      end

      app.get "/sidetiq/:name/schedule" do
        halt 404 unless (name = params[:name])

        @time = Sidetiq.clock.gettime

        @worker, @schedule = Sidetiq.schedules.select do |worker, _|
          worker.name == name
        end.flatten

        erb File.read(File.join(VIEWS, 'sidetiq_schedule.erb'))
      end

      app.get "/sidetiq/:name/history" do
        halt 404 unless (name = params[:name])

        @time = Sidetiq.clock.gettime

        @worker, @schedule = Sidetiq.schedules.select do |worker, _|
          worker.name == name
        end.flatten

        @history = Sidekiq.redis do |redis|
          redis.lrange("sidetiq:#{@worker.name}:history", 0, -1)
        end

        erb File.read(File.join(VIEWS, 'sidetiq_history.erb'))
      end

      app.post "/sidetiq/:name/trigger" do
        halt 404 unless (name = params[:name])

        worker, _ = Sidetiq.schedules.select do |w, _|
          w.name == name
        end.flatten

        worker.perform_async

        redirect "#{root_path}sidetiq"
      end
    end
  end
end

Sidekiq::Web.register(Sidetiq::Web)
Sidekiq::Web.tabs["Sidetiq"] = "sidetiq"

