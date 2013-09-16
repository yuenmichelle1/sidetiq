module Sidetiq
  module Lock
    class Redis
      include Logging

      attr_reader :key, :timeout

      def initialize(key, timeout = Sidetiq.config.lock_expire)
        @key = key.kind_of?(Class) ? "sidetiq:#{key.name}:lock" : "sidetiq:#{key}:lock"
        @timeout = timeout
      end

      def synchronize
        Sidekiq.redis do |redis|
          acquired, meta = lock(redis)

          if acquired
            debug "Lock: #{meta}"

            begin
              yield redis
            ensure
              unlock(redis)
              debug "Unlock: #{key}"
            end
          end
        end
      end

      private

      def lock(redis)
        acquired, meta = false, nil

        watch(redis, key) do
          if !redis.exists(key)
            acquired = !!redis.multi do |multi|
              meta = MetaData.for_new_lock(key)
              multi.psetex(key, timeout, meta.to_json)
            end
          end
        end

        [acquired, meta]
      end

      def unlock(redis)
        watch(redis, key) do
          meta = MetaData.from_json(redis.get(key))

          if meta.owner == Sidetiq::Lock::MetaData::OWNER
            redis.multi do |multi|
              multi.del(key)
            end
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
end
