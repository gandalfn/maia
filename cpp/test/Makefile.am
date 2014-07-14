include $(top_srcdir)/build-aux/maia.am
include $(top_srcdir)/build-aux/test.am

TESTS = test

check_PROGRAMS = \
    test

AM_CPPFLAGS = \
	-std=c++11 \
	$(MAIAMM_CFLAGS) \
	-I${top_srcdir}/lib \
	-I${top_srcdir}/lib/core \
	-I${top_srcdir}/cpp

test_SOURCES = \
    test.cc \
    test-case.cc \
    test-case.h \
    test-manifest.cc \
    test-manifest.h \
    test-canvas.cc \
    test-canvas.h \
    test-event.cc \
    test-event.h \
    test-model.cc \
    test-model.h

test_LDFLAGS = \
	-Wl,--as-needed

test_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    $(MAIAMM_LIBS) \
    ${top_builddir}/lib/libmaia.la \
    ${top_builddir}/cpp/maiamm/libmaiamm.la
