SUBDIRS = codegen src maiamm gtk . doc

maiamm.h:
	$(AM_V_GEN) $(top_srcdir)/tools/generate-mm-global-header maiamm $(srcdir)/maiamm > $@

clean-local:
	rm -f maiamm.h

all-local: maiamm.h
