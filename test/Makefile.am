include $(top_srcdir)/build/maia.am

INCLUDES += \
    -I${top_builddir}/src/core

noinst_PROGRAMS = maia-test

maia_test_VALAFLAGS = \
    --vapidir=${top_builddir}/src/core \
    --pkg=maia-core

maia_test_SOURCES = \
    maia-test.vala \
    maia-test-case.vala \
    core/maia-test-core.vala \
    core/maia-test-task-queue.vala

maia_test_LDADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/src/core/libmaia-core.la

VALAFILES = \
    $(filter %.vala,$(maia_test_SOURCES))

CLEANFILES += \
    maia_test_vala.stamp \
    $(VALAFILES:.vala=.c)
