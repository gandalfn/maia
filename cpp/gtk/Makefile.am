SUBDIRS = src maia-gtkmm .

MAIA_LIB_NAME = maia-gtkmm

includedir = $(prefix)/include/maia-gtkmm-$(MAIA_ABI)

maia-gtkmm.h:
	$(AM_V_GEN) $(top_srcdir)/tools/generate-mm-global-header maia-gtkmm $(srcdir)/maia-gtkmm gtkmm,maiamm > $@

include_HEADERS = \
	maia-gtkmm.h

EXTRA_DIST = \
	maia-gtkmm.h

CLEANFILES = \
	maia-gtkmm.h

include $(top_srcdir)/build-aux/pkgconfig.am
