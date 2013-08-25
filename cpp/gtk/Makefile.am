SUBDIRS = src maia-gtkmm .

maia-gtkmm.h:
	$(AM_V_GEN) $(top_srcdir)/tools/generate-mm-global-header maia-gtkmm $(srcdir)/maia-gtkmm maiamm > $@

clean-local:
	rm -f maia-gtkmm.h

all-local: maia-gtkmm.h
