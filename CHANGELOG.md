0.3.6
-----

- Better protection against stale locks and race-conditions.

  Locking is now done using WATCH/MULTI/EXEC/UNWATCH and additionally
  includes a host and process specific identifier to prevent accidental
  unlocks from other Sidekiq processes.

- Fix Sidetiq::Schedulable documentation.

0.3.5
-----

- Use Clock#mon_synchronize instead of #synchronize.

  ActiveSupport's core extensions override Module#synchronize which seems to
  break MonitorMixin.

0.3.4
-----

- More robust #perform arity handling.

0.3.3
-----

- Deprecate Sidekiq::Schedulable.tiq in favor of .recurrence.
  Sidekiq::Schedulable.tiq will still work until v0.4.0 but log
  a deprecation warning.

0.3.2
-----

- Fix tests to work with changes to Sidekiq::Client.
  #push_old seems to expect 'at' instead of 'enqueued_at' now
- Switch from MIT to 3-clause BSD license.
- Remove C extension.
- Bump Sidekiq dependency to ~> 2.13.0.
- Ensure redis locks get unlocked in Clock#synchronize_clockworks.

0.3.1
-----

- Bump ice_cube dependency to ~> 0.11.0.
- Bump Sidekiq dependency to ~> 2.12.0.
- Fix tests.

0.3.0
-----

- Add `Sidetiq.schedules`.
- Add `Sidetiq.workers`.
- Add `Sidetiq.scheduled`.
- Add `Sidetiq.retries`.
- Add `Sidetiq.logger`. This defaults to the Sidekiq logger.
- Add support for job backfills.
- Clean up tests.
- Sidetiq::Schedule no longer inherits from IceCube::Schedule.

0.2.0
-----

- Add class methods to get last and next scheduled occurrence.
- Pass last and next (current) occurrence to #perform, if desired.
  This checks the method arity of #perform.
- Bump Sidekiq dependency to 2.8.0
- Fix incorrectly assigned Thread priority.
- Adjust clock sleep depending of execution time of the last tick.
- Don't log thread object ids.
- Issue a warning from the middleware if the clock thread died previously.

0.1.5
-----

- Allow jobs to be scheduled for immediate runs via the web extension.
