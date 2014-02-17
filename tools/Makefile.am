MAIA_VAPI_DEPS = \
    maia \
    core/maia-any \
    gtk/maia-gtk

include $(top_srcdir)/build-aux/maia.am

if USE_VALGRIND
INCLUDES += $(MAIA_VALGRIND_CFLAGS)
endif

bin_PROGRAMS = \
    canvas-editor

INCLUDES += \
    $(MAIA_GTK_CFLAGS) \
    $(MAIA_CANVAS_EDITOR_CFLAGS)

ui_DATA = \
    canvas-editor.ui

sourceview_DATA = \
    manifest.lang

canvas_editor_VALAFLAGS = \
    --pkg=config \
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

canvas_editor_LDFLAGS = \
    -Wl,--as-needed \
    -Wl,--no-add-needed

canvas_editor_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_GTK_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    $(MAIA_CANVAS_EDITOR_LIBS) \
    ${top_builddir}/lib/libmaia.la \
    ${top_builddir}/lib/gtk/libmaia-gtk.la \
    ${top_builddir}/lib/cairo/libmaia-cairo-graphic.la \
    ${top_builddir}/lib/gdk-pixbuf/libmaia-gdk-pixbuf.la

VALAFILES = \
    $(filter %.vala,$(canvas_editor_SOURCES))

CLEANFILES += \
    canvas_editor_vala.stamp \
    $(VALAFILES:.vala=.c)

EXTRA_DIST += \
    $(ui_DATA) \
    $(sourceview_DATA)
