MAIA_LIB_NAME = maia-cairo-graphic

MAIA_VAPI_DEPS =  \
    core/maia-any \
    maia

include $(top_srcdir)/build-aux/maia.am
include $(top_srcdir)/build-aux/pkgconfig.am
include $(top_srcdir)/build-aux/backend.am
include $(top_srcdir)/build-aux/vapi.am

backend_LTLIBRARIES = libmaia-cairo-graphic.la

libmaia_cairo_graphic_la_CFLAGS = \
    $(MAIA_CAIRO_CFLAGS)

libmaia_cairo_graphic_la_VALAFLAGS = \
    --pkg=cairo \
    --pkg=cairo-xcb \
    --pkg=pangocairo \
    --pkg=xcb

libmaia_cairo_graphic_la_SOURCES = \
    fixed.vala \
    rectangle.vala \
    region.vala \
    init.vala \
    surface.vala \
    context.vala \
    glyph.vala \
    image-png.vala

libmaia_cairo_graphic_la_LIBADD = \
    $(MAIA_CAIRO_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_cairo_graphic_la_SOURCES))

CLEANFILES += \
    libmaia_cairo_graphic_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
