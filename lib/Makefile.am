MAIA_LIB_NAME = maia

MAIA_VAPI_DEPS = \
    $(top_builddir)/lib/core/maia-core-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/xml/maia-xml-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/graphic/maia-graphic-$(MAIA_ABI).vapi

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

SUBDIRS = core xml graphic . xcb

AM_CFLAGS += \
    -DMAIA_LOG_CONTEXT=\""Maia"\"

maia.h: libmaia_la_vala.stamp

lib_LTLIBRARIES = libmaia.la

include_HEADERS = \
    maia.h

libmaia_la_VALAFLAGS = \
    --use-header \
    --header=maia.h \
    --library=maia

libmaia_la_SOURCES = \
    view.vala \
    desktop.vala \
    desktop-proxy.vala \
    workspace.vala \
    workspace-proxy.vala \
    window.vala \
    window-proxy.vala \
    damage-event.vala \
    delete-event.vala \
    application.vala

libmaia_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_la_LIBADD = \
    $(MAIA_LIBS) \
    $(top_builddir)/lib/core/libmaia-core.la \
    $(top_builddir)/lib/xml/libmaia-xml.la \
    $(top_builddir)/lib/graphic/libmaia-graphic.la

VALAFILES = \
    $(filter %.vala,$(libmaia_la_SOURCES))

CLEANFILES += \
    maia.h \
    libmaia_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
