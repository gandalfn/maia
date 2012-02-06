MAIA_LIB_NAME = maia-core

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

maia-core.h: libmaia_core_la_vala.stamp

lib_LTLIBRARIES = libmaia-core.la

includecoredir = $(includedir)/core

includecore_HEADERS = \
    maia-core.h

libmaia_core_la_VALAFLAGS = \
    --header=maia-core.h \
    --library=maia-core

libmaia_core_la_SOURCES = \
    logger.vala \
    functions.vala \
    backoff.vala \
    iterator.vala \
    collection.vala \
    array.vala \
    queue.vala \
    list.vala \
    set.vala \
    pair.vala \
    map.vala \
    atom.vala \
    spinlock.vala \
    read-write-spinlock.vala \
    atomic-node.vala \
    atomic-stack.vala \
    atomic-queue.vala \
    atomic-list.vala \
    object.vala \
    transform.vala \
    point.vala \
    size.vala \
    rectangle.vala \
    region.vala \
    task.vala \
    task-once.vala \
    watch.vala \
    timeout.vala \
    tictac.vala \
    timeline.vala \
    dispatcher.vala \
    parser.vala \
    notification.vala \
    event.vala \
    event-args.vala \
    event-listener.vala \
    event-dispatcher.vala

libmaia_core_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_core_la_LIBADD = \
    $(MAIA_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_core_la_SOURCES))

CLEANFILES += \
    maia-core.h \
    libmaia_core_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)

