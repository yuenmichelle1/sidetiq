require 'sidekiq/web'

module Sidetiq
  module Web
    VIEWS = File.expand_path('views', File.dirname(__FILE__))

    def self.registered(app)
      app.get "/sidetiq" do
        clock = Sidetiq::Clock.instance
        @schedules = clock.schedules
        @time = clock.gettime
        slim File.read(File.join(VIEWS, 'sidetiq.slim'))
      end

      app.get "/sidetiq/:name" do
        halt 404 unless (name = params[:name])

        clock = Sidetiq::Clock.instance
        schedules = clock.schedules

        @time = clock.gettime

        @worker, @schedule = schedules.select do |worker, schedule|
          worker.name == name
        end.flatten

        slim File.read(File.join(VIEWS, 'sidetiq_details.slim'))
      end
    end
  end
end

Sidekiq::Web.register(Sidetiq::Web)

if Sidekiq::Web.tabs.is_a?(Array)
  Sidekiq::Web.tabs << "sidetiq"
else
  Sidekiq::Web.tabs["Sidetiq"] = "sidetiq"
end

