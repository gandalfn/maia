MAIA_LIB_NAME = maia
MAIA_VAPI_DEPS = $(top_builddir)/src/core/maia-core-$(MAIA_ABI).vapi

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

SUBDIRS = core

maia.h: libmaia_la_vala.stamp

lib_LTLIBRARIES = libmaia.la

include_HEADERS = \
    maia.h

libmaia_la_VALAFLAGS = \
    --use-header \
    --header=maia.h \
    --library=maia

libmaia_la_SOURCES = \
    maia-backend.vala \
    maia-context.vala \
    maia-view.vala \
    maia-screen.vala

libmaia_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_la_LIBADD = \
    $(MAIA_LIBS) \
    $(top_builddir)/src/core/libmaia-core.la

VALAFILES = \
    $(filter %.vala,$(libmaia_la_SOURCES))

CLEANFILES += \
    maia.h \
    libmaia_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
