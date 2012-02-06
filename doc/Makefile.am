if ENABLE_VALADOC

VALADOC_SRCS = \
    $(top_srcdir)/lib/core/*.vala \
    $(top_srcdir)/lib/graphic/*.vala \
    $(top_srcdir)/lib/xml/*.vala \
    $(top_srcdir)/lib/*.vala

VALADOC_FLAGS = \
    --vapidir @VALA_VAPI_PATH@ \
    --vapidir $(top_srcdir)/vapi \
    --vapidir $(top_srcdir)/lib/core \
    --pkg pixman-1 \
    --pkg os \
    --pkg machine \
    --pkg log \
    -b $(top_srcdir)/lib \
    --package-name Maia \
    --package-version @MAIA_VERSION@

valadoc-html: $(VALADOC_SRCS)
	$(AM_V_GEN) rm -rf html; \
	$(VALADOC) --deps -o html $(VALADOC_FLAGS) $(VALADOC_SRCS) && \
	touch $@

valadoc-devhelp: $(VALADOC_SRCS)
	$(AM_V_GEN) rm -rf devhelp; \
	$(VALADOC) -o devhelp --doclet devhelp $(VALADOC_FLAGS) $(VALADOC_SRCS) && \
	touch $@

clean-local:
	rm -rf html devhelp; \
	rm -f valadoc-html valadoc-devhelp

uninstall-hook:
	rm -rf $(DESTDIR)$(datadir)/devhelp/books/Maia

install-data-hook: devhelp
	$(MKDIR_P) $(DESTDIR)$(datadir)/devhelp/books/Maia/img
	$(INSTALL_DATA) -t $(DESTDIR)$(datadir)/devhelp/books/Maia devhelp/Maia/*.*
	$(INSTALL_DATA) -t $(DESTDIR)$(datadir)/devhelp/books/Maia/img devhelp/Maia/img/*

all-local: valadoc-html valadoc-devhelp

.NOTPARALLEL: valadoc-html valadoc-devhelp

endif

