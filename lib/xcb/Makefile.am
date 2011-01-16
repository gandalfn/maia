MAIA_LIB_NAME = maia-xcb-backend

MAIA_VAPI_DEPS = \
    $(top_builddir)/lib/core/maia-core-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/xml/maia-xml-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/graphic/maia-graphic-$(MAIA_ABI).vapi \
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
    --use-header \
    --header=maia-xcb-backend.h \
    --library=maia-xcb-backend \
    --pkg=xcb-1.0 \
    --pkg=xcb-atom

libmaia_xcb_backend_la_SOURCES = \
    xcb-desktop.vala \
    xcb-workspace.vala

libmaia_xcb_backend_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_xcb_backend_la_LIBADD = \
    $(MAIA_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_xcb_backend_la_SOURCES))

CLEANFILES += \
    maia-xcb-backend.h \
    libmaia_xcb_backend_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
