MAIA_LIB_NAME = maia-gdk-pixbuf

MAIA_VAPI_DEPS =  \
    core/maia-any \
    maia

include $(top_srcdir)/build-aux/maia.am
include $(top_srcdir)/build-aux/backend.am
include $(top_srcdir)/build-aux/pkgconfig.am
include $(top_srcdir)/build-aux/vapi.am

backend_LTLIBRARIES = libmaia-gdk-pixbuf.la

libmaia_gdk_pixbuf_la_CFLAGS = \
    $(MAIA_GDK_PIXBUF_CFLAGS)

libmaia_gdk_pixbuf_la_VALAFLAGS = \
    --pkg=gdk-pixbuf-2.0

libmaia_gdk_pixbuf_la_SOURCES = \
    image.vala \
    image-png.vala \
    image-jpg.vala \
    image-svg.vala \
    image-gif.vala \
    image-pixbuf.vala \
    init.vala

libmaia_gdk_pixbuf_la_LIBADD = \
    $(MAIA_GDK_PIXBUF_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_gdk_pixbuf_la_SOURCES))

CLEANFILES += \
    libmaia_gdk_pixbuf_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
