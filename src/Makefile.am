include $(top_srcdir)/build/maia.am

maia.h: libmaia_la_vala.stamp

maia-0.1.vapi: libmaia_la_vala.stamp

lib_LTLIBRARIES = libmaia.la

include_HEADERS = \
    maia.h \
    maia-object.h \
    maia-source.h

libmaia_la_VALAFLAGS = \
    --use-header \
    --header=maia.h \
    --library=maia-0.1

libmaia_la_SOURCES = \
    maia-object.c \
    maia-source.c \
    maia-timeout.vala \
    maia-timeout-interval.vala \
    maia-timeout-pool.vala \
    maia-timeline.vala

libmaia_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_la_LIBADD = \
    $(MAIA_LIBS)

pkgconfig_DATA = maia-0.1.pc

vapi_DATA = maia-0.1.vapi

VALAFILES = \
    $(filter %.vala,$(libmaia_la_SOURCES))

EXTRA_DIST = \
    libmaia-0.1.pc.in

CLEANFILES = \
    maia.h \
    maia-0.1.vapi \
    libmaia_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
