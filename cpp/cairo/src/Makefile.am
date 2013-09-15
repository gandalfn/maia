binding_name    = maia-cairo-graphicmm
wrap_init_flags = --namespace=Maia --namespace=Cairo --parent_dir=maia-cairo-graphicmm
codegen_srcdir  = $(top_builddir)/cpp/codegen

maia-cairo-graphic_signals.defs: $(top_srcdir)/lib/cairo/maia-cairo-graphic.h
	$(AM_V_GEN) $(top_builddir)/cpp/codegen/extradefs/generate_maia_cairo_defs > $@

maia-cairo-graphic_methods.defs: $(top_srcdir)/lib/cairo/maia-cairo-graphic.h
	$(AM_V_GEN) $(top_builddir)/cpp/codegen/h2def/h2def.py $^ > $@

maia-cairo-graphic_enums.defs: $(top_srcdir)/lib/cairo/maia-cairo-graphic.h
	$(AM_V_GEN) $(top_builddir)/cpp/codegen/enum.pl $^ > $@

maia-cairo-graphic_docs.xml: $(top_srcdir)/doc/mm/maia_docs.xml
	$(AM_V_GEN) cp $< $@

include $(srcdir)/filelist.am
include $(top_srcdir)/cpp/codegen/m4/filelist.am
include $(top_srcdir)/build-aux/generate-binding.am

MAINTAINERCLEANFILES += \
	maia-cairo-graphic_docs.xml
