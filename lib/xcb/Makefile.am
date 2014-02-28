MAIA_LIB_NAME = maia-xcb

MAIA_VAPI_DEPS =  \
    core/maia-any \
    cairo/maia-cairo-graphic \
    maia

include $(top_srcdir)/build-aux/maia.am
include $(top_srcdir)/build-aux/pkgconfig.am
include $(top_srcdir)/build-aux/backend.am
include $(top_srcdir)/build-aux/vapi.am

backend_LTLIBRARIES = libmaia-xcb.la

libmaia_xcb_la_CFLAGS = \
    $(MAIA_CAIRO_CFLAGS) \
    $(MAIA_XCB_CFLAGS)

libmaia_xcb_la_VALAFLAGS = \
    --pkg=xcb

libmaia_xcb_la_SOURCES = \
    init.vala \
    connection-watch.vala \
    application.vala \
    pixmap.vala \
    window.vala

libmaia_xcb_la_LIBADD = \
    $(MAIA_XCB_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_xcb_la_SOURCES))

CLEANFILES += \
    libmaia_xcb_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
