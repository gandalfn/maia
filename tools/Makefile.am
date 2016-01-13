MAIA_VAPI_DEPS = \
    maia \
    core/maia-any

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
    --pkg=x11 \
    --pkg=gtk+-2.0 \
    --pkg=gtksourceview-2.0

canvas_editor_SOURCES = \
    canvas-editor.vala \
    window.vala \
    sourceview.vala \
    engine.vala \
    provider.vala

canvas_editor_LDFLAGS = \
    -Wl,--as-needed

canvas_editor_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    $(MAIA_CANVAS_EDITOR_LIBS) \
    ${top_builddir}/lib/libmaia.la

VALAFILES = \
    $(filter %.vala,$(canvas_editor_SOURCES))

CLEANFILES += \
    canvas_editor_vala.stamp \
    $(VALAFILES:.vala=.c)

EXTRA_DIST += \
    $(ui_DATA) \
    $(sourceview_DATA)
