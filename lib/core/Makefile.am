MAIA_LIB_NAME = maia-core

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

AM_CFLAGS += \
    -DG_LOG_DOMAIN=\""Maia.Core"\"

maia-core.h: libmaia_core_la_vala.stamp

lib_LTLIBRARIES = libmaia-core.la

includecoredir = $(includedir)/core

includecore_HEADERS = \
    maia-core.h

libmaia_core_la_VALAFLAGS = \
    --use-header \
    --header=maia-core.h \
    --library=maia-core

libmaia_core_la_SOURCES = \
    functions.vala \
    iterator.vala \
    collection.vala \
    array.vala \
    list.vala \
    set.vala \
    pair.vala \
    map.vala \
    object.vala \
    notification.vala \
    observer.vala \
    log.vala \
    transform.vala \
    point.vala \
    size.vala \
    rectangle.vala \
    region.vala \
    task.vala \
    watch.vala \
    timeout.vala \
    dispatcher.vala \
    parser.vala \
    core.vala

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
