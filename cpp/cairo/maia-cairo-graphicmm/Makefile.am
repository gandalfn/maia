lib_LTLIBRARIES = libmaia-cairo-graphicmm.la

binding_modulename = maia-cairo-graphicmm-$(MAIA_ABI)

include $(srcdir)/../src/filelist.am
include $(srcdir)/filelist.am
include $(top_srcdir)/build-aux/compile-binding.am

local_cppflags = $(binding_includes) $(binding_cppflags) -DSKELETONMM_BUILD=1

AM_CPPFLAGS = \
	$(local_cppflags) \
	$(GTHREAD_CFLAGS) \
	$(MAIA_CFLAGS) \
    $(MAIA_CAIRO_CFLAGS) \
    $(MAIAMM_CFLAGS) \
	$(MAIA_CAIROMM_CFLAGS) \
	-I${top_srcdir}/lib \
	-I${top_srcdir}/lib/core \
	-I${top_srcdir}/lib/cairo \
	-I${top_srcdir}/cpp \
	-I${top_srcdir}/cpp/maia-cairo-graphicmm

AM_CXXFLAGS = $(MAIAMM_WXXFLAGS)

libmaia_cairo_graphicmm_la_SOURCES = $(binding_sources)
libmaia_cairo_graphicmm_la_LDFLAGS = -no-undefined -version-info @MAIA_SO_VERSION@
libmaia_cairo_graphicmm_la_LIBADD  = \
	$(MAIA_LIBS) \
    $(MAIA_CAIRO_LIBS) \
    $(MAIA_VALGRIND_LIBS) \
    ${top_builddir}/lib/libmaia.la \
    ${top_builddir}/lib/cairo/libmaia-cairo-graphic.la
