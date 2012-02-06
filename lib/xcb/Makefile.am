MAIA_LIB_NAME = maia-xcb-backend

MAIA_VAPI_DEPS = \
    $(top_builddir)/lib/core/maia-core-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/xml/maia-xml-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/graphic/maia-graphic-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/cairo/maia-cairo-graphic-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/maia-$(MAIA_ABI).vapi

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

maia-xcb-backend.h: libmaia_xcb_backend_la_vala.stamp

lib_LTLIBRARIES = libmaia-xcb-backend.la

includexcbbackenddir = $(includedir)/xcb-backend

includexcbbackend_HEADERS = \
    maia-xcb-backend.h

libmaia_xcb_backend_la_VALAFLAGS = \
    --header=maia-xcb-backend.h \
    --library=maia-xcb-backend \
    --pkg=xcb-1.0 \
    --pkg=cairo

libmaia_xcb_backend_la_SOURCES = \
    xcb-atom.vala \
    xcb-desktop.vala \
    xcb-workspace.vala \
    xcb-window.vala \
    xcb-request.vala \
    xcb-window-attributes.vala \
    xcb-window-geometry.vala \
    xcb-window-property.vala \
    xcb-window-icccm-properties.vala \
    xcb-window-ewmh-properties.vala \
    xcb-window-graphic-device.vala \
    xcb-offscreen-graphic-device.vala \
    xcb-damage-event.vala \
    xcb-geometry-event.vala \
    xcb-delete-event.vala \
    xcb-client-message-event.vala \
    xcb-create-window-event.vala \
    xcb-destroy-window-event.vala \
    xcb-reparent-window-event.vala \
    xcb-redraw-dispatcher.vala \
    xcb-event-dispatcher.vala \
    xcb-application.vala \
    xcb-backend.vala

libmaia_xcb_backend_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_xcb_backend_la_LIBADD = \
    $(MAIA_LIBS) \
    $(top_builddir)/lib/cairo/libmaia-cairo-graphic.la

VALAFILES = \
    $(filter %.vala,$(libmaia_xcb_backend_la_SOURCES))

CLEANFILES += \
    maia-xcb-backend.h \
    libmaia_xcb_backend_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)

