MAIA_LIB_NAME = maia-rsvg

MAIA_VAPI_DEPS =  \
    core/maia-any \
    maia

include $(top_srcdir)/build-aux/maia.am
include $(top_srcdir)/build-aux/backend.am
include $(top_srcdir)/build-aux/pkgconfig.am
include $(top_srcdir)/build-aux/vapi.am

backend_LTLIBRARIES = libmaia-rsvg.la

libmaia_rsvg_la_CFLAGS = \
    $(MAIA_RSVG_CFLAGS)

libmaia_rsvg_la_VALAFLAGS = \
    --pkg=cairo \
    --pkg=gdk-pixbuf-2.0 \
    --pkg=librsvg-2.0 \
    -D $(MAIA_RSVG_VERSION)

libmaia_rsvg_la_SOURCES = \
    image-svg.vala \
    init.vala

libmaia_rsvg_la_LIBADD = \
    $(MAIA_RSVG_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_rsvg_la_SOURCES))

CLEANFILES += \
    libmaia_rsvg_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
