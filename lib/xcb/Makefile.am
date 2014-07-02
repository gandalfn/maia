MAIA_LIB_NAME = maia-xcb

MAIA_VAPI_DEPS =  \
    core/maia-any \
    maia

include $(top_srcdir)/build-aux/maia.am
include $(top_srcdir)/build-aux/pkgconfig.am
include $(top_srcdir)/build-aux/backend.am
include $(top_srcdir)/build-aux/vapi.am

keysym.vala:
	$(AM_V_GEN) $(top_srcdir)/tools/generate-xcb-key-convert > $@

backend_LTLIBRARIES = libmaia-xcb.la

libmaia_xcb_la_CFLAGS = \
    $(MAIA_XCB_CFLAGS)

libmaia_xcb_la_VALAFLAGS = \
    --pkg=xcb \
    --pkg=xcb-composite \
    --pkg=xcb-render-util \
    --pkg=xcb-keysyms \
    --pkg=xcb-keysym \
    --pkg=xcb-cursor \
    --pkg=xcb-cursorfont

libmaia_xcb_la_SOURCES = \
    init.vala \
    keysym.vala \
    cursor.vala \
    connection-watch.vala \
    atoms.vala \
    application.vala \
    delete-event-args.vala \
    drawable.vala \
    pixmap.vala \
    request.vala \
    window.vala

libmaia_xcb_la_LIBADD = \
    $(MAIA_XCB_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_xcb_la_SOURCES))

CLEANFILES += \
    keysym.vala \
    libmaia_xcb_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
