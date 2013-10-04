SUBDIRS = src maia-cairo-graphicmm .

MAIA_LIB_NAME = maia-cairo-graphicmm

includedir = $(prefix)/include/maia-cairo-graphicmm-$(MAIA_ABI)

maia-cairo-graphicmm.h:
	$(AM_V_GEN) $(top_srcdir)/tools/generate-mm-global-header maia-cairo-graphicmm $(srcdir)/maia-cairo-graphicmm cairomm/cairomm,maiamm > $@

include_HEADERS = \
	maia-cairo-graphicmm.h

EXTRA_DIST = \
	maia-cairo-graphicmm.h

CLEANFILES = \
	maia-cairo-graphicmm.h

include $(top_srcdir)/build-aux/pkgconfig.am
