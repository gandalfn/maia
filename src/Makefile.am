include $(top_srcdir)/build/maia.am

maia.h: libmaia_la_vala.stamp

lib_LTLIBRARIES = libmaia.la

include_HEADERS = \
    maia.h

includebase_HEADERS = \
    base/maia-object.h \
    base/maia-source.h

libmaia_la_VALAFLAGS = \
    --use-header \
    --header=maia.h \
    --library=maia

libmaia_la_SOURCES = \
    base/maia-object.c \
    base/maia-source.c \
    timeline/maia-timeout.vala \
    timeline/maia-timeout-interval.vala \
    timeline/maia-timeout-pool.vala \
    timeline/maia-timeline.vala

libmaia_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_la_LIBADD = \
    $(MAIA_LIBS)

pkgconfig_DATA = maia-0.1.pc

VALAFILES = \
    $(filter %.vala,$(libmaia_la_SOURCES))

EXTRA_DIST = \
    libmaia-0.1.pc.in

CLEANFILES = \
    maia.h \
    maia.vapi \
    libmaia_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
