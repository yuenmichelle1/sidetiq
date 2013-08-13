module Sidetiq
  class Lock # :nodoc: all
    attr_reader :key, :timeout

    OWNER = "#{Socket.gethostname}:#{Process.pid}"

    def initialize(key, timeout = Sidetiq.config.lock_expire)
      @key  = key.kind_of?(Class) ? "sidetiq:#{key.name}:lock" : "sidetiq:#{key}:lock"
      @timeout   = timeout
    end

    def synchronize
      Sidekiq.redis do |redis|
        if lock(redis)

          begin
            yield redis
          ensure
            unlock(redis)
          end
        end
      end
    end

    private

    def lock(redis)
      acquired = false

      watch(redis, key) do
        if !redis.exists(key)
          acquired = !!redis.multi do |multi|
            multi.psetex(key, timeout, OWNER)
          end
        end
      end

      Sidetiq.logger.info "Sidetiq::Clock lock #{key}" if acquired

      acquired
    end

    def unlock(redis)
      watch(redis, key) do
        if redis.get(key) == OWNER
          redis.multi do |multi|
            multi.del(key)
          end

          Sidetiq.logger.info "Sidetiq::Clock unlock #{key}"
        end
      end
    end

    def watch(redis, *args)
      redis.watch(*args)

      begin
        yield
      ensure
        redis.unwatch
      end
    end
  end
end
