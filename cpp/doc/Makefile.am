if ENABLE_VALADOC

include $(top_srcdir)/cpp/src/filelist.am
include $(top_srcdir)/cpp/maiamm/filelist.am

maiamm_files_h = $(files_built_h) $(filter-out wrap_init.h,$(files_extra_h))

book_name = $(MAIAMM_MODULE_NAME)
doc_input = \
	$(top_srcdir)/cpp/maiamm/*.h \
	$(addprefix $(top_srcdir)/cpp/maiamm/,$(maiamm_files_h))

include $(top_srcdir)/build-aux/doc-reference.am

EXTRA_DIST = \
	doc-install.pl \
	doc-postprocess.pl \
	doxygen-extra.css \
	doxygen.css \
	tagfile-to-devhelp2.xsl \
	reference/doxygen.css

endif
