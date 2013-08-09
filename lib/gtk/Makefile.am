MAIA_LIB_NAME = maia-gtk

MAIA_VAPI_DEPS =  \
    core/maia-any \
    cairo/maia-cairo-graphic \
    gdk-pixbuf/maia-gdk-pixbuf \
    maia

include $(top_srcdir)/build-aux/maia.am
include $(top_srcdir)/build-aux/pkgconfig.am
include $(top_srcdir)/build-aux/vapi.am

keysym.vala:
	$(AM_V_GEN) $(top_srcdir)/tools/generate-gdk-key-convert > $@

lib_LTLIBRARIES = libmaia-gtk.la

libmaia_gtk_la_CFLAGS = \
    $(MAIA_GTK_CFLAGS)

libmaia_gtk_la_VALAFLAGS = \
    --pkg=gdk-keysym \
    --pkg=gtk+-2.0

libmaia_gtk_la_SOURCES = \
    keysym.vala \
    surface.vala \
    image.vala \
    canvas.vala

libmaia_gtk_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_gtk_la_LIBADD = \
    $(MAIA_LIBS) \
    $(MAIA_GDK_PIXBUF_LIBS) \
    $(MAIA_CAIRO_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_gtk_la_SOURCES))

CLEANFILES += \
    keysym.vala \
    libmaia_gtk_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
