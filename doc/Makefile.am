if ENABLE_VALADOC

VALADOC_SRCS = \
	$(top_builddir)/lib/core/maia-any-$(MAIA_ABI).vapi \
    $(top_srcdir)/lib/core/*.vala \
    $(top_srcdir)/lib/protocol/*.vala \
    $(top_srcdir)/lib/cassowary/*.vala \
    $(top_srcdir)/lib/graphic/*.vala \
    $(top_srcdir)/lib/manifest/*.vala \
    $(top_srcdir)/lib/*.vala

VALADOC_FLAGS = \
	--force \
    -D GLIB_2_32 \
    -D $(MAIA_RSVG_VERSION) \
    --target-glib=2.32 \
    -b $(top_srcdir)/lib \
    -b $(top_srcdir)/lib/core \
    --vapidir $(top_srcdir)/vapi \
    --vapidir $(top_builddir)/lib/core \
    --pkg config \
    --pkg posix \
    --pkg os \
    --pkg libintl \
    --pkg glib-2.0 \
    --pkg gio-2.0 \
    --pkg gmodule-2.0 \
    --pkg gio-unix-2.0 \
    --pkg gvalue-collect \
    --package-name Maia \
    --package-version @MAIA_VERSION@

cpp/libdoclet.so: cpp/doclet.vala
	$(AM_V_GEN) mkdir -p $(builddir)/cpp && \
	$(VALAC) \
	    --pkg posix \
	    --pkg glib-2.0 \
	    --pkg gio-2.0 \
	    --pkg gio-unix-2.0 \
	    --pkg=valadoc-1.0 -b $(srcdir)/doc/cpp -d $(builddir)/cpp -C $(srcdir)/cpp/doclet.vala && \
	$(CC) -shared -fPIC -o $(top_builddir)/doc/cpp/libdoclet.so $(MAIA_VALADOC_CFLAGS) $(MAIA_VALADOC_LIBS) $(top_builddir)/doc/cpp/doclet.c

valadoc-html: $(VALADOC_SRCS)
	$(AM_V_GEN) rm -rf html; \
	$(VALADOC) -o html $(VALADOC_FLAGS) $(VALADOC_SRCS) && \
	touch $@

valadoc-devhelp: $(VALADOC_SRCS)
	$(AM_V_GEN) rm -rf devhelp; \
	$(VALADOC) -o devhelp --doclet devhelp $(VALADOC_FLAGS) $(VALADOC_SRCS) && \
	touch $@

valadoc-mm: $(VALADOC_SRCS)
	$(AM_V_GEN) rm -rf mm; \
	$(VALADOC) -o mm --doclet cpp $(VALADOC_FLAGS) $(VALADOC_SRCS) && \
	touch $@

clean-local:
	rm -rf html devhelp mm; \
	rm -f valadoc-html valadoc-devhelp valadoc-mm; \
	rm -f cpp/doclet.c; \
	rm -f cpp/libdoclet.so

uninstall-hook:
	rm -rf $(DESTDIR)$(datadir)/devhelp/books/Maia

install-data-hook: devhelp
	$(MKDIR_P) $(DESTDIR)$(datadir)/devhelp/books/Maia/img
	$(INSTALL_DATA) -t $(DESTDIR)$(datadir)/devhelp/books/Maia devhelp/Maia/*.*
	$(INSTALL_DATA) -t $(DESTDIR)$(datadir)/devhelp/books/Maia/img devhelp/Maia/img/*

all-local: cpp/libdoclet.so valadoc-html valadoc-devhelp valadoc-mm

EXTRA_DIST = \
	cpp/doclet.vala

.NOTPARALLEL: cpp/libdoclet.so valadoc-html valadoc-devhelp valadoc-mm

endif
