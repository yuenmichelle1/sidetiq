require 'sidekiq/web'

module Sidetiq
  module Web
    VIEWS = File.expand_path('views', File.dirname(__FILE__))

    def self.registered(app)
      app.helpers do
        def sidetiq_clock
          Sidetiq::Clock.instance
        end

        def sidetiq_schedules
          sidetiq_clock.schedules
        end
      end

      app.get "/sidetiq" do
        @schedules = sidetiq_schedules
        @time = sidetiq_clock.gettime
        erb File.read(File.join(VIEWS, 'sidetiq.erb'))
      end

      app.get "/sidetiq/:name" do
        halt 404 unless (name = params[:name])

        @time = sidetiq_clock.gettime

        @worker, @schedule = sidetiq_schedules.select do |worker, _|
          worker.name == name
        end.flatten

        erb File.read(File.join(VIEWS, 'sidetiq_details.erb'))
      end

      app.post "/sidetiq/:name/trigger" do
        halt 404 unless (name = params[:name])

        worker, _ = sidetiq_schedules.select do |w, _|
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

