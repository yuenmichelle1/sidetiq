#include <ruby.h>
#include <assert.h>
#include "sidetiq_ext.h"

#ifdef __APPLE__
#include <sys/time.h>
#include <sys/resource.h>
#include <mach/mach.h>
#include <mach/clock.h>
#include <mach/mach_time.h>
#include <errno.h>
#include <unistd.h>
#include <sched.h>
#else
#include <time.h>
#endif

VALUE msidetiq;
VALUE esidetiq_error;
VALUE csidetiq_clock;

#ifdef __APPLE__
static mach_timebase_info_data_t clock_gettime_inf;

typedef enum {
        CLOCK_REALTIME,
        CLOCK_MONOTONIC,
        CLOCK_PROCESS_CPUTIME_ID,
        CLOCK_THREAD_CPUTIME_ID
} clockid_t;

int clock_gettime(clockid_t clk_id, struct timespec *tp)
{
        kern_return_t ret;
        clock_serv_t clk;
        clock_id_t clk_serv_id;
        mach_timespec_t tm;
        uint64_t start, end, delta, nano;
        int retval = -1;

        switch (clk_id) {
                case CLOCK_REALTIME:
                case CLOCK_MONOTONIC:
                        clk_serv_id = clk_id == CLOCK_REALTIME ? CALENDAR_CLOCK : SYSTEM_CLOCK;
                        if (KERN_SUCCESS == (ret = host_get_clock_service(mach_host_self(), clk_serv_id, &clk))) {
                                if (KERN_SUCCESS == (ret = clock_get_time(clk, &tm))) {
                                        tp->tv_sec  = tm.tv_sec;
                                        tp->tv_nsec = tm.tv_nsec;
                                        retval = 0;
                                }
                        }
                        if (KERN_SUCCESS != ret) {
                                errno = EINVAL;
                                retval = -1;
                        }
                break;
                case CLOCK_PROCESS_CPUTIME_ID:
                case CLOCK_THREAD_CPUTIME_ID:
                        start = mach_absolute_time();
                        if (clk_id == CLOCK_PROCESS_CPUTIME_ID) {
                                getpid();
                        } else {
                                sched_yield();
                        }
                        end = mach_absolute_time();
                        delta = end - start;
                        if (0 == clock_gettime_inf.denom) {
                                mach_timebase_info(&clock_gettime_inf);
                        }
                        nano = delta * clock_gettime_inf.numer / clock_gettime_inf.denom;
                        tp->tv_sec = nano * 1e-9;
                        tp->tv_nsec = nano - (tp->tv_sec * 1e9);
                        retval = 0;
                break;
                default:
                        errno = EINVAL;
                        retval = -1;
        }
        return retval;
}
#endif

static VALUE sidetiq_gettime(VALUE self)
{
        struct timespec time;
        assert(clock_gettime(CLOCK_REALTIME, &time) == 0);
        return rb_time_nano_new(time.tv_sec, time.tv_nsec);
}

void Init_sidetiq_ext()
{
        msidetiq = rb_define_module("Sidetiq");
        esidetiq_error = rb_define_class_under(msidetiq, "Error", rb_eStandardError);
        csidetiq_clock = rb_define_class_under(msidetiq, "Clock", rb_cObject);
        rb_define_method(csidetiq_clock, "gettime", sidetiq_gettime, 0);
}

