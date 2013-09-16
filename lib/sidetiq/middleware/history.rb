module Sidetiq
  module Middleware
    class History
      def call(worker, msg, queue, &block)
        if worker.kind_of?(Sidetiq::Schedulable)
          call_with_sidetiq_history(worker, msg, queue, &block)
        else
          yield
        end
      end

      def call_with_sidetiq_history(worker, msg, queue)
        entry = {
          status: :success,
          error: "",
          exception: "",
          backtrace: "",
          processor: "#{Socket.gethostname}:#{Process.pid}-#{Thread.current.object_id}",
          processed: Time.now.iso8601
        }

        yield
      rescue StandardError => e
        entry[:status] = :failure
        entry[:exception] = e.class.to_s
        entry[:error] = e.message
        entry[:backtrace] = e.backtrace

        raise e
      ensure
        Sidekiq.redis do |redis|
          redis.pipelined do |pipe|
            list_name = "sidetiq:#{worker.class.name}:history"

            pipe.lpush(list_name, JSON.dump(entry))
            pipe.ltrim(list_name, 0, Sidetiq.config.worker_history - 1)
          end
        end
      end
    end
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidetiq::Middleware::History
  end
end
