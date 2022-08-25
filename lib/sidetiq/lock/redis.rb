module Sidetiq
  module Lock
    class Redis
      include Logging

      attr_reader :key, :timeout

      def self.all
        Sidekiq.redis do |redis|
          redis.keys("sidetiq:*:lock").map do |key|
            new(key)
          end
        end
      end

      def initialize(key, timeout = Sidetiq.config.lock_expire)
        @key = extract_key(key)
        @timeout = timeout
      end

      def synchronize
        debug "Inside Lock::Redis.synchronize"
        Sidekiq.redis do |redis|
          debug "Inside Sidekiq.Redis Object within Lock::Redis.synchronize"
          acquired = lock
          debug "Acquired? #{acquired} within Lock::Redis.synchronize"

          if acquired
            debug "Lock: #{key}"

            begin
              yield redis
            ensure
              unlock
              debug "Unlock: #{key}"
            end
          end
        end
      end

      def stale?
        pttl = meta_data.pttl

        # Consider PTTL of -1 (never set) and larger than the
        # configured lock_expire as invalid. Locks with timestamps
        # older than 1 minute are also considered stale.
        pttl < 0 || pttl >= Sidetiq.config.lock_expire ||
          meta_data.timestamp < (Sidetiq.clock.gettime.to_i - 60)
      end

      def meta_data
        @meta_data ||= Sidekiq.redis do |redis|
          MetaData.from_json(redis.get(key))
        end
      end

      def lock
        Sidekiq.redis do |redis|
          acquired = false
          debug "INSIDE LOCK Definition in Redis"
          watch(redis, key) do
            debug "Inside WATCH DO in redis.db"
            debug "key #{key}"
            debug "redis exists key? #{redis.exists(key)}"
            if !redis.exists(key)
              debug "Inside !redis exists in redis.rb"
              acquired = !!redis.multi do |multi|
                debug "Inside acquired equals #{multi} in redis.rb"
                meta = MetaData.for_new_lock(key)
                debug "Inside meta definition #{meta.to_json}"
                multi.psetex(key, timeout, meta.to_json)
              end
            end
          end

          acquired
        end
      end

      def unlock
        Sidekiq.redis do |redis|
          watch(redis, key) do
            if meta_data.owner == Sidetiq::Lock::MetaData::OWNER
              redis.multi do |multi|
                multi.del(key)
              end

              true
            else
              false
            end
          end
        end
      end

      def unlock!
        Sidekiq.redis do |redis|
          redis.del(key)
        end
      end

      private

      def extract_key(key)
        case key
        when Class
          "sidetiq:#{key.name}:lock"
        when String
          key.match(/sidetiq:(.+):lock/) ? key : "sidetiq:#{key}:lock"
        end
      end

      def watch(redis, *args)
        debug "Inside watch in redis.rb #{redis.watch(*args)}"
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
