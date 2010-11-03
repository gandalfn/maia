MAIA_VAPI_DEPS = \
    $(top_builddir)/src/maia-$(MAIA_ABI).vapi \
    $(top_builddir)/src/core/maia-core-$(MAIA_ABI).vapi \
    $(top_builddir)/src/xml/maia-xml-$(MAIA_ABI).vapi

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
    core/maia-test-task-queue.vala

maia_test_LDADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/src/libmaia.la \
    ${top_builddir}/src/core/libmaia-core.la

VALAFILES = \
    $(filter %.vala,$(maia_test_SOURCES))

CLEANFILES += \
    maia_test_vala.stamp \
    $(VALAFILES:.vala=.c)
