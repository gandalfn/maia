includelibdir = $(includedir)

MAIA_LIB_NAME = maia

MAIA_VAPI_DEPS = \
    core/maia-core \
    manifest/maia-manifest \
    xml/maia-xml \
    graphic/maia-graphic

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

SUBDIRS = core xml manifest cassowary graphic . cairo xcb

lib_LTLIBRARIES = libmaia.la

libmaia_la_SOURCES = \
    application.vala \
    input.vala \
    view.vala \
    double-buffer-view.vala \
    workspace.vala \
    window.vala \
    geometry-event.vala \
    damage-event.vala \
    repair-event.vala \
    delete-event.vala \
    create-window-event.vala \
    destroy-window-event.vala \
    reparent-window-event.vala \
    widget.vala \
    label.vala

libmaia_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_la_LIBADD = \
    $(MAIA_LIBS) \
    $(top_builddir)/lib/core/libmaia-core.la \
    $(top_builddir)/lib/xml/libmaia-xml.la \
    $(top_builddir)/lib/manifest/libmaia-manifest.la \
    $(top_builddir)/lib/graphic/libmaia-graphic.la

VALAFILES = \
    $(filter %.vala,$(libmaia_la_SOURCES))

CLEANFILES += \
    libmaia_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
