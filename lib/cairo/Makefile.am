MAIA_LIB_NAME = maia-cairo-graphic

MAIA_VAPI_DEPS = \
    $(top_builddir)/lib/core/maia-core-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/xml/maia-xml-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/graphic/maia-graphic-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/maia-$(MAIA_ABI).vapi

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

maia-cairo-graphic.h: libmaia_cairo_graphic_la_vala.stamp

lib_LTLIBRARIES = libmaia-cairo-graphic.la

includecairographicdir = $(includedir)/cairo-graphic

includecairographic_HEADERS = \
    maia-cairo-graphic.h

libmaia_cairo_graphic_la_VALAFLAGS = \
    --header=maia-cairo-graphic.h \
    --library=maia-cairo-graphic \
    --pkg=cairo

libmaia_cairo_graphic_la_SOURCES = \
    cairo-graphic-context.vala \
    cairo-graphic-device.vala \
    cairo-graphic-paint.vala \
    cairo-graphic-pattern.vala \
    cairo-graphic-shape.vala

libmaia_cairo_graphic_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_cairo_graphic_la_LIBADD = \
    $(MAIA_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_cairo_graphic_la_SOURCES))

CLEANFILES += \
    maia-cairo-graphic.h \
    libmaia_cairo_graphic_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)

