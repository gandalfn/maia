if ENABLE_VALADOC

VALADOC_SRCS = \
	$(top_srcdir)/lib/core/maia-any-$(MAIA_ABI).vapi \
    $(top_srcdir)/lib/core/*.vala \
    $(top_srcdir)/lib/graphic/*.vala \
    $(top_srcdir)/lib/manifest/*.vala \
    $(top_srcdir)/lib/cassowary/*.vala \
    $(top_srcdir)/lib/xml/*.vala \
    $(top_srcdir)/lib/*.vala

VALADOC_FLAGS = \
    -D GLIB_2_32 \
    --target-glib=2.32 \
    -b $(top_srcdir)/lib \
    -b $(top_srcdir)/lib/core \
    --vapidir $(top_srcdir)/vapi \
    --vapidir $(top_srcdir)/lib/core \
    --pkg machine \
    --pkg posix \
    --pkg os \
    --pkg glib-2.0 \
    --pkg gio-2.0 \
    --pkg gio-unix-2.0 \
    --package-name Maia \
    --package-version @MAIA_VERSION@

valadoc-html: $(VALADOC_SRCS)
	$(AM_V_GEN) rm -rf html; \
	$(VALADOC) -o html $(VALADOC_FLAGS) $(VALADOC_SRCS) && \
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
