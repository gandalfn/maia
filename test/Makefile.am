MAIA_VAPI_DEPS = \
    $(top_builddir)/lib/maia-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/core/maia-core-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/xml/maia-xml-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/graphic/maia-graphic-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/xcb/maia-xcb-backend-$(MAIA_ABI).vapi

include $(top_srcdir)/build/maia.am

noinst_PROGRAMS = test

test_SOURCES = \
    test.vala \
    test-case.vala \
    core/test-core.vala \
    core/test-array.vala \
    core/test-list.vala \
    core/test-set.vala \
    core/test-map.vala \
    core/test-object.vala \
    core/test-dispatcher.vala \
    core/test-application.vala \
    xml/test-xml.vala \
    xml/test-parser.vala

test_LDADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/lib/libmaia.la \
    ${top_builddir}/lib/core/libmaia-core.la \
    ${top_builddir}/lib/xml/libmaia-xml.la \
    ${top_builddir}/lib/xcb/libmaia-xcb-backend.la \
    /usr/lib/libprofiler.so.0

VALAFILES = \
    $(filter %.vala,$(test_SOURCES))

CLEANFILES += \
    test_vala.stamp \
    $(VALAFILES:.vala=.c)
