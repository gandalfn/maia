include $(top_srcdir)/build-aux/maia.am

noinst_PROGRAMS = \
    test

AM_CPPFLAGS = \
	$(MAIAMM_CFLAGS) \
	$(MAIA_GTKMM_CFLAGS) \
	-I${top_srcdir}/lib \
	-I${top_srcdir}/lib/core \
	-I${top_srcdir}/lib/cairo \
	-I${top_srcdir}/lib/gtk \
	-I${top_srcdir}/cpp \
	-I${top_srcdir}/cpp/gtk

test_SOURCES = \
    test.cc \
    test-case.cc \
    test-case.h \
    test-manifest.cc \
    test-manifest.h \
    test-canvas.cc \
    test-canvas.h \
    test-derived.cc \
    test-derived.h

test_LDADD = \
    $(MAIA_LIBS) \
    $(MAIA_GTK_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    $(MAIAMM_LIBS) \
    $(MAIA_GTKMM_LIBS) \
    ${top_builddir}/lib/libmaia.la \
    ${top_builddir}/lib/gdk-pixbuf/libmaia-gdk-pixbuf.la \
    ${top_builddir}/lib/gtk/libmaia-gtk.la \
    ${top_builddir}/cpp/maiamm/libmaiamm.la \
    ${top_builddir}/cpp/gtk/maia-gtkmm/libmaia-gtkmm.la
