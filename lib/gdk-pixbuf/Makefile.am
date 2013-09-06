MAIA_LIB_NAME = maia-gdk-pixbuf

MAIA_VAPI_DEPS =  \
    core/maia-any \
    cairo/maia-cairo-graphic \
    maia

include $(top_srcdir)/build-aux/maia.am
include $(top_srcdir)/build-aux/pkgconfig.am
include $(top_srcdir)/build-aux/vapi.am

lib_LTLIBRARIES = libmaia-gdk-pixbuf.la

libmaia_gdk_pixbuf_la_CFLAGS = \
    $(MAIA_CAIRO_CFLAGS) \
    $(MAIA_GDK_PIXBUF_CFLAGS)

libmaia_gdk_pixbuf_la_VALAFLAGS = \
    --pkg=gdk-pixbuf-2.0 \
    --pkg=cairo

libmaia_gdk_pixbuf_la_SOURCES = \
    image.vala \
    image-png.vala \
    image-jpg.vala \
    image-svg.vala \
    image-gif.vala \
    init.vala

libmaia_gdk_pixbuf_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_gdk_pixbuf_la_LIBADD = \
    $(MAIA_LIBS) \
    $(MAIA_CAIRO_LIBS) \
    $(MAIA_GDK_PIXBUF_LIBS) \
    $(top_builddir)/lib/libmaia.la \
    $(top_builddir)/lib/cairo/libmaia-cairo-graphic.la

VALAFILES = \
    $(filter %.vala,$(libmaia_gdk_pixbuf_la_SOURCES))

CLEANFILES += \
    libmaia_gdk_pixbuf_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
