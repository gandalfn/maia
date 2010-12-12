MAIA_VAPI_DEPS = \
    $(top_builddir)/lib/maia-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/core/maia-core-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/xml/maia-xml-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/graphic/maia-graphic-$(MAIA_ABI).vapi

include $(top_srcdir)/build/maia.am

noinst_PROGRAMS = maia-test

maia_test_SOURCES = \
    maia-test.vala \
    maia-test-case.vala \
    core/maia-test-core.vala \
    core/maia-test-array.vala \
    core/maia-test-list.vala \
    core/maia-test-set.vala \
    core/maia-test-map.vala \
    core/maia-test-object.vala \
    core/maia-test-notification.vala \
    core/maia-test-dispatcher.vala \
    xml/maia-test-xml.vala \
    xml/maia-test-parser.vala

maia_test_LDADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/lib/libmaia.la \
    ${top_builddir}/lib/core/libmaia-core.la \
    ${top_builddir}/lib/xml/libmaia-xml.la

VALAFILES = \
    $(filter %.vala,$(maia_test_SOURCES))

CLEANFILES += \
    maia_test_vala.stamp \
    $(VALAFILES:.vala=.c)
