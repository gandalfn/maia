lib_LTLIBRARIES = libmaia-gtkmm.la

binding_modulename = maia-gtkmm-$(MAIA_ABI)

include $(srcdir)/../src/filelist.am
include $(srcdir)/filelist.am
include $(top_srcdir)/build-aux/compile-binding.am

local_cppflags = $(binding_includes) $(binding_cppflags) -DSKELETONMM_BUILD=1

AM_CPPFLAGS = \
	$(local_cppflags) \
	$(GTHREAD_CFLAGS) \
	$(MAIA_GTKMM_CFLAGS) \
	-I${top_srcdir}/lib \
	-I${top_srcdir}/lib/core \
	-I${top_srcdir}/lib/gtk \
	-I${top_srcdir}/cpp \
	-I${top_srcdir}/cpp/gtk

AM_CXXFLAGS = $(MAIAMM_WXXFLAGS)

libmaia_gtkmm_la_SOURCES = $(binding_sources)
libmaia_gtkmm_la_LDFLAGS = -no-undefined -version-number @MAIA_SO_VERSION@
libmaia_gtkmm_la_LIBADD  = \
	$(MAIA_LIBS) \
    $(MAIA_CAIRO_LIBS) \
    $(MAIA_GDK_PIXBUF_LIBS) \
    $(MAIA_GTK_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    ${top_builddir}/lib/libmaia.la \
    ${top_builddir}/lib/cairo/libmaia-cairo-graphic.la \
    ${top_builddir}/lib/rsvg/libmaia-rsvg.la \
    ${top_builddir}/lib/gdk-pixbuf/libmaia-gdk-pixbuf.la \
    ${top_builddir}/lib/gtk/libmaia-gtk.la
