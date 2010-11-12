MAIA_LIB_NAME = maia-core
MAIA_EXTRA_VAPIS = source.vapi

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

maia-core.h: libmaia_core_la_vala.stamp

lib_LTLIBRARIES = libmaia-core.la

includecoredir = $(includedir)/core

includecore_HEADERS = \
    maia-source.h \
    maia-core.h

libmaia_core_la_VALAFLAGS = \
    --use-header \
    --header=maia-core.h \
    --library=maia-core

libmaia_core_la_SOURCES = \
    maia-source.c \
    maia-object.vala \
    maia-value.vala \
    maia-utils.vala \
    maia-iterator.vala \
    maia-collection.vala \
    maia-pair.vala \
    maia-array.vala \
    maia-set.vala \
    maia-map.vala \
    maia-list.vala \
    maia-transform.vala \
    maia-point.vala \
    maia-size.vala \
    maia-rectangle.vala \
    maia-region.vala \
    maia-parser.vala \
    maia-notification.vala \
    maia-task.vala \
    maia-task-queue.vala

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
