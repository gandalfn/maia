MAIA_VAPI_DEPS = \
    maia \
    core/maia-core \
    xml/maia-xml \
    graphic/maia-graphic \
    cairo/maia-cairo-graphic

include $(top_srcdir)/build/maia.am

if USE_VALGRIND
INCLUDES += $(MAIA_VALGRIND_CFLAGS)
endif

noinst_PROGRAMS = \
    test \
    test-window \
    test-atomic-queue

test_VALAFLAGS = \
    --pkg=xcb-1.0 \
    --pkg=cairo

test_SOURCES = \
    test.vala \
    test-case.vala \
    core/test-core.vala \
    core/test-atom.vala \
    core/test-spinlock.vala \
    core/test-array.vala \
    core/test-list.vala \
    core/test-set.vala \
    core/test-map.vala \
    core/test-object.vala \
    core/test-dispatcher.vala \
    core/test-application.vala \
    core/test-event.vala \
    xml/test-xml.vala \
    xml/test-parser.vala

test_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    ${top_builddir}/lib/libmaia.la \
    ${top_builddir}/lib/core/libmaia-core.la \
    ${top_builddir}/lib/xml/libmaia-xml.la \
    ${top_builddir}/lib/graphic/libmaia-graphic.la \
    ${top_builddir}/lib/cairo/libmaia-cairo-graphic.la \
    ${top_builddir}/lib/xcb/libmaia-xcb-backend.la

if USE_VALGRIND
test_LDADD += $(MAIA_VALGRIND_LIBS)
endif

test_window_SOURCES = \
    test-window.vala

test_window_VALAFLAGS = \
    --pkg=xcb-1.0 \
    --pkg=cairo

test_window_LDADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/lib/libmaia.la \
    ${top_builddir}/lib/core/libmaia-core.la \
    ${top_builddir}/lib/xml/libmaia-xml.la \
    ${top_builddir}/lib/graphic/libmaia-graphic.la \
    ${top_builddir}/lib/cairo/libmaia-cairo-graphic.la \
    ${top_builddir}/lib/xcb/libmaia-xcb-backend.la

if USE_VALGRIND
test_window_LDADD += $(MAIA_VALGRIND_LIBS)
endif

test_thread_SOURCES = \
    test-thread.vala

test_thread_LDADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/lib/core/libmaia-core.la

if USE_VALGRIND
test_thread_LDADD += $(MAIA_VALGRIND_LIBS)
endif

test_atomic_queue_SOURCES = \
    test-atomic-queue.vala

test_atomic_queue_LDADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/lib/core/libmaia-core.la

if USE_VALGRIND
test_atomic_queue_LDADD += $(MAIA_VALGRIND_LIBS)
endif

VALAFILES = \
    $(filter %.vala,$(test_SOURCES)) \
    $(filter %.vala,$(test_window_SOURCES)) \
    $(filter %.vala,$(test_atomic_queue_SOURCES)) \
    $(filter %.vala,$(test_thread_SOURCES))

CLEANFILES += \
    test_vala.stamp \
    $(VALAFILES:.vala=.c)
