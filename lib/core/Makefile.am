MAIA_EXTRA_VAPIS = maia-any.vapi

includelibdir = $(includedir)/core

MAIA_LIB_NAME = maia-core

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

lib_LTLIBRARIES = libmaia-core.la

if USE_VALGRIND
libmaia_core_la_VALAFLAGS = \
    --pkg=valgrind \
    --define=USE_VALGRIND
endif

libmaia_core_la_SOURCES = \
    any.c \
    maia-any.h \
    logger.vala \
    functions.vala \
    value.vala \
    iterator.vala \
    collection.vala \
    array.vala \
    queue.vala \
    list.vala \
    set.vala \
    pair.vala \
    map.vala \
    spinlock.vala \
    object.vala \
    state-machine.vala \
    task.vala \
    source.vala \
    watch.vala \
    timeout.vala \
    timeout-pool.vala \
    dispatcher.vala \
    event-args.vala \
    event.vala \
    event-listener.vala \
    parser.vala \
    node.vala

libmaia_core_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_core_la_LIBADD = \
    $(MAIA_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_core_la_SOURCES))

CLEANFILES += \
    libmaia_core_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
