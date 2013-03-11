# stdlib
require 'monitor'
require 'ostruct'
require 'singleton'

# gems
require 'ice_cube'
require 'sidekiq'

# c extensions
require 'sidetiq_ext'

# internal
require 'sidetiq/config'
require 'sidetiq/clock'
require 'sidetiq/middleware'
require 'sidetiq/schedule'
require 'sidetiq/schedulable'
require 'sidetiq/version'

# The Sidetiq namespace.
module Sidetiq
  # Public: Returns an Array of workers including Sidetiq::Schedulable.
  def self.workers
    schedules.keys
  end

  # Public: Returns a Hash of Sidetiq::Schedule instances.
  def self.schedules
    Clock.synchronize do
      Clock.schedules.dup
    end
  end

  # Public: Currently scheduled recurring jobs.
  #
  # worker - A Sidekiq::Worker class or String of the class name (optional)
  # block  - An optional block that can be given to which each
  #          Sidekiq::SortedEntry instance corresponding to a scheduled job will
  #          be yielded.
  #
  # Examples
  #
  #   Sidetiq.scheduled
  #   # => [#<Sidekiq::SortedEntry>, ...]
  #
  #   Sidetiq.scheduled(MyWorker)
  #   # => [#<Sidekiq::SortedEntry>, ...]
  #
  #   Sidetiq.scheduled("MyWorker")
  #   # => [#<Sidekiq::SortedEntry>, ...]
  #
  #   Sidetiq.scheduled do |job|
  #     # do stuff ...
  #   end
  #   # => [#<Sidekiq::SortedEntry>, ...]
  #
  #   Sidetiq.scheduled(MyWorker) do |job|
  #     # do stuff ...
  #   end
  #   # => [#<Sidekiq::SortedEntry>, ...]
  #
  #   Sidetiq.scheduled("MyWorker") do |job|
  #     # do stuff ...
  #   end
  #   # => [#<Sidekiq::SortedEntry>, ...]
  #
  # Yields each Sidekiq::SortedEntry instance.
  # Returns an Array of Sidekiq::SortedEntry objects.
  def self.scheduled(worker = nil, &block)
    worker = worker.constantize if worker.kind_of?(String)

    scheduled = Sidekiq::ScheduledSet.new.select do |job|
      klass = job.klass.constantize
      ret = klass.include?(Schedulable)
      ret = ret && klass == worker if worker
      ret
    end

    scheduled.each(&block) if block_given?

    scheduled
  end
end

