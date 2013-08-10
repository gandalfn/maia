MAIA_LIB_NAME = maia-rsvg

MAIA_VAPI_DEPS =  \
    core/maia-any \
    cairo/maia-cairo-graphic \
    maia

include $(top_srcdir)/build-aux/maia.am
include $(top_srcdir)/build-aux/pkgconfig.am
include $(top_srcdir)/build-aux/vapi.am

lib_LTLIBRARIES = libmaia-rsvg.la

libmaia_rsvg_la_CFLAGS = \
    $(MAIA_CAIRO_CFLAGS) \
    $(MAIA_RSVG_CFLAGS)

libmaia_rsvg_la_VALAFLAGS = \
    --pkg=cairo \
    --pkg=librsvg-2.0

libmaia_rsvg_la_SOURCES = \
    image-svg.vala \
    init.vala

libmaia_rsvg_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_rsvg_la_LIBADD = \
    $(MAIA_LIBS) \
    $(MAIA_CAIRO_LIBS) \
    $(MAIA_RSVG_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_rsvg_la_SOURCES))

CLEANFILES += \
    libmaia_rsvg_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
