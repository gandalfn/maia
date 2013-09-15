binding_name    = maia-gtkmm
wrap_init_flags = --namespace=Maia --namespace=Gtk --parent_dir=maia-gtkmm
codegen_srcdir  = $(top_builddir)/cpp/codegen

maia-gtk_signals.defs: $(top_srcdir)/lib/gtk/maia-gtk.h
	$(AM_V_GEN) $(top_builddir)/cpp/codegen/extradefs/generate_maia_gtk_defs > $@

maia-gtk_methods.defs: $(top_srcdir)/lib/gtk/maia-gtk.h
	$(AM_V_GEN) $(top_builddir)/cpp/codegen/h2def/h2def.py $^ > $@

maia-gtk_enums.defs: $(top_srcdir)/lib/gtk/maia-gtk.h
	$(AM_V_GEN) $(top_builddir)/cpp/codegen/enum.pl $^ > $@

maia-gtk_docs.xml: $(top_srcdir)/doc/mm/maia_docs.xml
	$(AM_V_GEN) cp $< $@

include $(srcdir)/filelist.am
include $(top_srcdir)/cpp/codegen/m4/filelist.am
include $(top_srcdir)/build-aux/generate-binding.am

MAINTAINERCLEANFILES += \
	maia-gtk_docs.xml
