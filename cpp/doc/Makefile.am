if ENABLE_VALADOC

include $(top_srcdir)/cpp/src/filelist.am
include $(top_srcdir)/cpp/maiamm/filelist.am

maiamm_files_h = $(files_built_h) $(filter-out wrap_init.h,$(files_extra_h))

include $(top_srcdir)/cpp/gtk/src/filelist.am
include $(top_srcdir)/cpp/gtk/maia-gtkmm/filelist.am

maia_gtkmm_files_h = $(files_built_h) $(filter-out wrap_init.h,$(files_extra_h))

maiamm_files_h = $(files_built_h) $(filter-out wrap_init.h,$(files_extra_h))

book_name = $(MAIAMM_MODULE_NAME)
doc_input = \
	$(top_srcdir)/cpp/maiamm/*.h \
	$(top_srcdir)/cpp/gtk/maia-gtkmm/*.h \
	$(addprefix $(top_srcdir)/cpp/maiamm/,$(maiamm_files_h)) \
	$(addprefix $(top_srcdir)/cpp/gtk/maia-gtkmm/,$(maia_gtkmm_files_h))

include $(top_srcdir)/build-aux/doc-reference.am

EXTRA_DIST = reference/doxygen.css

endif
