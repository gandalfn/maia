includelibdir = $(includedir)/graphic

MAIA_LIB_NAME = maia-graphic

MAIA_VAPI_DEPS = \
    core/maia-core \
    manifest/maia-manifest

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

lib_LTLIBRARIES = libmaia-graphic.la

libmaia_graphic_la_SOURCES = \
    matrix.vala \
    transform.vala \
    point.vala \
    size.vala \
    rectangle.vala \
    region.vala \
    color.vala \
    path.vala \
    glyph.vala \
    context.vala \
    pattern.vala \
    device.vala

libmaia_graphic_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_graphic_la_LIBADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/lib/manifest/libmaia-manifest.la

VALAFILES = \
    $(filter %.vala,$(libmaia_graphic_la_SOURCES))

CLEANFILES += \
    libmaia_graphic_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
