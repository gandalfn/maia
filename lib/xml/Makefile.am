includelibdir = $(includedir)/xml

MAIA_LIB_NAME = maia-xml

MAIA_VAPI_DEPS = \
    core/maia-core

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

lib_LTLIBRARIES = libmaia-xml.la

libmaia_xml_la_SOURCES = \
    xml-parser.vala \
    xml-node.vala

libmaia_xml_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_xml_la_LIBADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/lib/core/libmaia-core.la

VALAFILES = \
    $(filter %.vala,$(libmaia_xml_la_SOURCES))

CLEANFILES += \
    libmaia_xml_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
