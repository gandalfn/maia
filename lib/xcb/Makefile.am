includelibdir = $(includedir)/xcb-backend

MAIA_LIB_NAME = maia-xcb-backend

MAIA_VAPI_DEPS = \
    core/maia-core \
    manifest/maia-manifest \
    xml/maia-xml \
    graphic/maia-graphic \
    cairo/maia-cairo-graphic \
    maia

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

lib_LTLIBRARIES = libmaia-xcb-backend.la

libmaia_xcb_backend_la_VALAFLAGS = \
    --pkg=xcb \
    --pkg=cairo \
    --pkg=cairo-xcb \
    --pkg=pangocairo

libmaia_xcb_backend_la_SOURCES = \
    xcb-atom.vala \
    xcb-cookie.vala \
    xcb-application.vala \
    xcb-event-dispatcher.vala \
    xcb-workspace.vala \
    xcb-input.vala \
    xcb-window.vala \
    xcb-create-window-event.vala \
    xcb-destroy-window-event.vala \
    xcb-geometry-event.vala \
    xcb-damage-event.vala \
    xcb-backend.vala

libmaia_xcb_backend_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_xcb_backend_la_LIBADD = \
    $(MAIA_LIBS) \
    $(top_builddir)/lib/manifest/libmaia-manifest.la \
    $(top_builddir)/lib/cairo/libmaia-cairo-graphic.la

VALAFILES = \
    $(filter %.vala,$(libmaia_xcb_backend_la_SOURCES))

CLEANFILES += \
    libmaia_xcb_backend_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
