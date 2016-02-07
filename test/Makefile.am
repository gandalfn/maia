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
    test-chart \
    test-glx \
    test-clone \
    test-bus-client \
    test-bus-server

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

test_clone_SOURCES = \
    test-clone.vala

test_clone_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    ${top_builddir}/lib/libmaia.la

test_glx_VALAFLAGS = \
    --pkg=gl

test_glx_SOURCES = \
    test-glx.vala

test_glx_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    -lGL \
    ${top_builddir}/lib/libmaia.la

test_chart_SOURCES = \
    test-chart.vala

test_chart_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    ${top_builddir}/lib/libmaia.la

test_bus_server_SOURCES = \
    test-bus-server.vala

test_bus_server_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    ${top_builddir}/lib/libmaia.la

test_bus_client_SOURCES = \
    test-bus-client.vala

test_bus_client_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    ${top_builddir}/lib/libmaia.la

VALAFILES = \
    $(filter %.vala,$(test_SOURCES)) \
    $(filter %.vala,$(test_xcb_SOURCES)) \
    $(filter %.vala,$(test_clone_SOURCES)) \
    $(filter %.vala,$(test_glx_SOURCES)) \
    $(filter %.vala,$(test_bus_server_SOURCES)) \
    $(filter %.vala,$(test_bus_client_SOURCES)) \
    $(filter %.vala,$(test_chart_SOURCES))

CLEANFILES += \
    test_vala.stamp \
    test_xcb_vala.stamp \
    test_clone_vala.stamp \
    test_glx_vala.stamp \
    test_chart_vala.stamp \
    test_bus_server_vala.stamp \
    test_bus_client_vala.stamp \
    $(VALAFILES:.vala=.c)
