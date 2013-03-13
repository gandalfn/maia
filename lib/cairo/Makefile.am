includelibdir = $(includedir)/cairo-graphic

MAIA_LIB_NAME = maia-cairo-graphic

MAIA_VAPI_DEPS = \
    core/maia-core \
    xml/maia-xml \
    graphic/maia-graphic \
    maia

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

lib_LTLIBRARIES = libmaia-cairo-graphic.la

libmaia_cairo_graphic_la_VALAFLAGS = \
    --pkg=cairo

libmaia_cairo_graphic_la_SOURCES = \
    fixed.vala \
    rectangle.vala \
    region.vala \
    init.vala \
    device.vala \
    context.vala

libmaia_cairo_graphic_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_cairo_graphic_la_LIBADD = \
    $(MAIA_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_cairo_graphic_la_SOURCES))

CLEANFILES += \
    libmaia_cairo_graphic_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
