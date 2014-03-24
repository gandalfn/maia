lib_LTLIBRARIES = libmaiamm.la

binding_modulename = maiamm-$(MAIA_ABI)

include $(srcdir)/../src/filelist.am
include $(srcdir)/filelist.am
include $(top_srcdir)/build-aux/compile-binding.am

local_cppflags = $(binding_includes) $(binding_cppflags) -DSKELETONMM_BUILD=1

AM_CPPFLAGS = -std=c++11 $(local_cppflags) $(GTHREAD_CFLAGS) $(MAIAMM_CFLAGS) -I${top_srcdir}/lib -I${top_srcdir}/lib/core -I${top_srcdir}/cpp/maiamm
AM_CXXFLAGS = $(MAIAMM_WXXFLAGS)

libmaiamm_la_SOURCES = $(binding_sources)
libmaiamm_la_LDFLAGS = -no-undefined -version-number @MAIA_SO_VERSION@
libmaiamm_la_LIBADD  = $(MAIAMM_LIBS) ${top_builddir}/lib/libmaia.la
