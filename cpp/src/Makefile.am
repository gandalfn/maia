binding_name    = maiamm
wrap_init_flags = --namespace=Maia --parent_dir=maiamm
codegen_srcdir  = $(top_srcdir)/cpp/codegen

maia_signals.defs: $(top_srcdir)/lib/maia.h $(top_srcdir)/lib/core/maia-any.h
	$(AM_V_GEN) $(top_builddir)/cpp/codegen/extradefs/generate_maia_defs > $@

maia_methods.defs: $(top_srcdir)/lib/maia.h $(top_srcdir)/lib/core/maia-any.h
	$(AM_V_GEN) $(top_builddir)/cpp/codegen/h2def/h2def.py $^ > $@

maia_enums.defs: $(top_srcdir)/lib/maia.h $(top_srcdir)/lib/core/maia-any.h
	$(AM_V_GEN) $(top_builddir)/cpp/codegen/enum.pl $^ > $@

maia_docs.xml: $(top_builddir)/doc/mm/maia_docs.xml
	$(AM_V_GEN) cp $< $@

include $(srcdir)/filelist.am
include $(top_srcdir)/cpp/codegen/m4/filelist.am
include $(top_srcdir)/build-aux/generate-binding.am

CLEANFILES = \
	maia_docs.xml
