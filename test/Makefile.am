MAIA_VAPI_DEPS = \
    maia \
    core/maia-any

include $(top_srcdir)/build-aux/maia.am
include $(top_srcdir)/build-aux/test.am

if USE_VALGRIND
INCLUDES += $(MAIA_VALGRIND_CFLAGS)
endif

TESTS = test

check_PROGRAMS = \
    test

noinst_PROGRAMS = \
    test-xcb \
    test-chart

INCLUDES += \
    $(MAIA_CAIRO_CFLAGS)

test_VALAFLAGS = \
    --pkg=cairo

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
    core/test-stack.vala \
    core/test-queue.vala \
    core/test-async-queue.vala \
    core/test-timeline.vala \
    core/test-bus.vala \
    core/test-notification.vala \
    core/test-protocol.vala \
    graphic/test-graphic.vala \
    graphic/test-transform.vala \
    manifest/test-manifest.vala \
    manifest/test-document.vala \
    cassowary/test-cassowary.vala

test_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_CAIRO_LIBS) \
    $(MAIA_GDK_PIXBUF_LIBS) \
    $(MAIA_GTK_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    ${top_builddir}/lib/libmaia.la

test_xcb_SOURCES = \
    test-xcb.vala

test_xcb_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    ${top_builddir}/lib/libmaia.la

test_chart_SOURCES = \
    test-chart.vala

test_chart_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    ${top_builddir}/lib/libmaia.la

VALAFILES = \
    $(filter %.vala,$(test_SOURCES)) \
    $(filter %.vala,$(test_xcb_SOURCES)) \
    $(filter %.vala,$(test_chart_SOURCES))

CLEANFILES += \
    test_vala.stamp \
    test_xcb_vala.stamp \
    test_chart_vala.stamp \
    $(VALAFILES:.vala=.c)
