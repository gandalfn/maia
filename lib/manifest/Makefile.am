includelibdir = $(includedir)/manifest

MAIA_LIB_NAME = maia-manifest

MAIA_VAPI_DEPS = \
    core/maia-core

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

lib_LTLIBRARIES = libmaia-manifest.la

libmaia_manifest_la_SOURCES = \
    document.vala \
    element.vala \
    attribute-scanner.vala \
    attribute.vala \
    attribute-bind.vala \
    function.vala

libmaia_manifest_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_manifest_la_LIBADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/lib/core/libmaia-core.la

VALAFILES = \
    $(filter %.vala,$(libmaia_manifest_la_SOURCES))

CLEANFILES += \
    libmaia_manifest_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
