MAIA_LIB_NAME = maia-xml

MAIA_VAPI_DEPS = \
    $(top_builddir)/lib/core/maia-core-$(MAIA_ABI).vapi

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

maia-xml.h: libmaia_xml_la_vala.stamp

lib_LTLIBRARIES = libmaia-xml.la

includexmldir = $(includedir)/xml

includexml_HEADERS = \
    maia-xml.h

libmaia_xml_la_VALAFLAGS = \
    --header=maia-xml.h \
    --library=maia-xml

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
    maia-xml.h \
    libmaia_xml_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)

