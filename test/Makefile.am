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
    test

INCLUDES += \
    $(MAIA_CAIRO_CFLAGS) \
    $(MAIA_RSVG_CFLAGS) \
    $(MAIA_GDK_PIXBUF_CFLAGS) \
    $(MAIA_GTK_CFLAGS)

test_VALAFLAGS = \
    --pkg=gtk+-2.0 \
    --pkg=cairo \
    --pkg=pangocairo \
    --pkg=librsvg-2.0

test_SOURCES = \
    test.vala \
    test-case.vala \
    core/test-core.vala \
    core/test-any.vala \
    core/test-object.vala \
    core/test-array.vala \
    core/test-list.vala \
    core/test-set.vala \
    core/test-map.vala \
    core/test-timeline.vala \
    graphic/test-graphic.vala \
    graphic/test-transform.vala \
    manifest/test-manifest.vala \
    manifest/test-document.vala \
    gtk/test-gtk.vala \
    gtk/test-model.vala \
    gtk/test-canvas.vala

test_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_CAIRO_LIBS) \
    $(MAIA_GDK_PIXBUF_LIBS) \
    $(MAIA_GTK_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    ${top_builddir}/lib/libmaia.la \
    ${top_builddir}/lib/cairo/libmaia-cairo-graphic.la \
    ${top_builddir}/lib/rsvg/libmaia-rsvg.la \
    ${top_builddir}/lib/gdk-pixbuf/libmaia-gdk-pixbuf.la \
    ${top_builddir}/lib/gtk/libmaia-gtk.la

VALAFILES = \
    $(filter %.vala,$(test_SOURCES))

CLEANFILES += \
    test_vala.stamp \
    $(VALAFILES:.vala=.c)
