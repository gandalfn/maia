MAIA_LIB_NAME = maia-gtk

MAIA_VAPI_DEPS =  \
    core/maia-any \
    maia \
    gdk-pixbuf/maia-gdk-pixbuf

MAIA_SYSTEM_VAPI_DEPS = \
    gtk+-2.0

include $(top_srcdir)/build-aux/maia.am
include $(top_srcdir)/build-aux/backend.am
include $(top_srcdir)/build-aux/pkgconfig.am
include $(top_srcdir)/build-aux/vapi.am

backend_LTLIBRARIES = libmaia-gtk.la

libmaia_gtk_la_CFLAGS = \
    $(MAIA_GTK_CFLAGS)

libmaia_gtk_la_VALAFLAGS = \
    --pkg=gdk-x11-2.0 \
    --pkg=gvalue-collect

libmaia_gtk_la_SOURCES = \
    init.vala \
    image.vala \
    button.vala \
    tool.vala \
    model.vala \
    canvas.vala \
    xembed.vala

libmaia_gtk_la_LIBADD = \
    $(MAIA_GTK_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_gtk_la_SOURCES))

CLEANFILES += \
    keysym.vala \
    libmaia_gtk_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
