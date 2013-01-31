#ifndef __SIDETIQ_EXT_H__
#define __SIDETIQ_EXT_H__
#include <ruby.h>

typedef uint64_t sidetiq_time_t;

void Init_sidetiq_ext();
static VALUE sidetiq_gettime(VALUE self);

/* module Sidetiq */
extern VALUE msidetiq;

/* class Sidetiq::Error < StandardError */
extern VALUE esidetiq_error;

/* class Sidetiq::Clock */
extern VALUE csidetiq_clock;

#endif
