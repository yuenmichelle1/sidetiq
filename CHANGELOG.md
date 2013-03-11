HEAD
----

- Add `Sidetiq.schedules`.
- Add `Sidetiq.workers`.
- Add `Sidetiq.scheduled`.
- Add `Sidetiq.retries`.
- Add `Sidetiq.logger`. This defaults to the Sidekiq logger.
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
