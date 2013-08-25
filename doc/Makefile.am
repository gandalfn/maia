if ENABLE_VALADOC

VALADOC_SRCS = \
	$(top_builddir)/lib/core/maia-any-$(MAIA_ABI).vapi \
    $(top_srcdir)/lib/core/*.vala \
    $(top_srcdir)/lib/graphic/*.vala \
    $(top_srcdir)/lib/manifest/*.vala \
    $(top_srcdir)/lib/*.vala \
    $(top_srcdir)/lib/cairo/*.vala \
    $(top_srcdir)/lib/gdk-pixbuf/*.vala \
    $(top_srcdir)/lib/gtk/*.vala \
    $(top_srcdir)/lib/rsvg/*.vala

VALADOC_FLAGS = \
    -D GLIB_2_32 \
    -D $(MAIA_RSVG_VERSION) \
    --target-glib=2.32 \
    -b $(top_srcdir)/lib \
    -b $(top_srcdir)/lib/core \
    --vapidir $(top_srcdir)/vapi \
    --vapidir $(top_builddir)/lib/core \
    --pkg posix \
    --pkg os \
    --pkg glib-2.0 \
    --pkg gio-2.0 \
    --pkg gio-unix-2.0 \
    --pkg cairo \
    --pkg pangocairo \
    --pkg gdk-keysym \
    --pkg gtk+-2.0 \
    --pkg librsvg-2.0 \
    --package-name Maia \
    --package-version @MAIA_VERSION@

cpp/libdoclet.so: cpp/doclet.vala
	$(AM_V_GEN) $(VALAC) --pkg=valadoc-1.0 -C cpp/doclet.vala && \
	$(CC) -shared -fPIC -o cpp/libdoclet.so $(MAIA_VALADOC_CFLAGS) $(MAIA_VALADOC_LIBS) cpp/doclet.c

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
	cp mm/maia_docs.xml $(top_srcdir)/cpp/src && \
	cp mm/maia_docs.xml $(top_srcdir)/cpp/gtk/src/maia-gtk_docs.xml && \
	touch $@

clean-local:
	rm -rf html devhelp mm; \
	rm -f valadoc-html valadoc-devhelp valadoc-mm; \
	rm -f cpp/doclet.c; \
	rm -f $(top_srcdir)/cpp/src/maia_docs.xml; \
	rm -f $(top_srcdir)/cpp/src/maia-gtk_docs.xml; \
	rm -f cpp/libdoclet.so

uninstall-hook:
	rm -rf $(DESTDIR)$(datadir)/devhelp/books/Maia

install-data-hook: devhelp
	$(MKDIR_P) $(DESTDIR)$(datadir)/devhelp/books/Maia/img
	$(INSTALL_DATA) -t $(DESTDIR)$(datadir)/devhelp/books/Maia devhelp/Maia/*.*
	$(INSTALL_DATA) -t $(DESTDIR)$(datadir)/devhelp/books/Maia/img devhelp/Maia/img/*

all-local: cpp/libdoclet.so valadoc-html valadoc-devhelp valadoc-mm

.NOTPARALLEL: cpp/libdoclet.so valadoc-html valadoc-devhelp valadoc-mm

endif
