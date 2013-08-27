MAIA_VAPI_DEPS = \
    maia \
    core/maia-any \
    cairo/maia-cairo-graphic \
    rsvg/maia-rsvg \
    gdk-pixbuf/maia-gdk-pixbuf \
    gtk/maia-gtk

include $(top_srcdir)/build-aux/maia.am

if USE_VALGRIND
INCLUDES += $(MAIA_VALGRIND_CFLAGS)
endif

noinst_PROGRAMS = \
    canvas-editor

INCLUDES += \
    $(MAIA_CAIRO_CFLAGS) \
    $(MAIA_RSVG_CFLAGS) \
    $(MAIA_GDK_PIXBUF_CFLAGS) \
    $(MAIA_GTK_CFLAGS) \
    $(MAIA_CANVAS_EDITOR_CFLAGS)

canvas_editor_VALAFLAGS = \
    --pkg=gtk+-2.0 \
    --pkg=gtksourceview-2.0 \
    --pkg=cairo \
    --pkg=pangocairo \
    --pkg=librsvg-2.0

canvas_editor_SOURCES = \
    canvas-editor.vala \
    window.vala \
    sourceview.vala \
    engine.vala \
    provider.vala

canvas_editor_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_CAIRO_LIBS) \
    $(MAIA_GDK_PIXBUF_LIBS) \
    $(MAIA_GTK_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    $(MAIA_CANVAS_EDITOR_LIBS) \
    ${top_builddir}/lib/libmaia.la \
    ${top_builddir}/lib/cairo/libmaia-cairo-graphic.la \
    ${top_builddir}/lib/rsvg/libmaia-rsvg.la \
    ${top_builddir}/lib/gdk-pixbuf/libmaia-gdk-pixbuf.la \
    ${top_builddir}/lib/gtk/libmaia-gtk.la

VALAFILES = \
    $(filter %.vala,$(canvas_editor_SOURCES))

CLEANFILES += \
    canvas_editor_vala.stamp \
    $(VALAFILES:.vala=.c)