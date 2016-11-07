if MAINTAINER_MODE
src_subdirs = codegen src
else
src_subdirs =
endif

SUBDIRS = $(src_subdirs) maiamm . doc test

MAIA_LIB_NAME = maiamm

includedir = $(prefix)/include/maiamm-$(MAIA_ABI)

maiamm.h:
	$(AM_V_GEN) $(top_srcdir)/tools/generate-mm-global-header maiamm $(srcdir)/maiamm glibmm > $@

include_HEADERS = \
	maiamm.h

EXTRA_DIST = \
	maiamm.h

CLEANFILES = \
	maiamm.h

include $(top_srcdir)/build-aux/pkgconfig.am
