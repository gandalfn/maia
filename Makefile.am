SUBDIRS = vapi lib doc cpp tools test

maiadocdir = ${prefix}/doc/maia
maiadoc_DATA = \
    README\
    COPYING\
    AUTHORS\
    ChangeLog\
    INSTALL\
    NEWS

BUILD_FILES = \
    build-aux/common.am \
    build-aux/backend.am \
    build-aux/pkgconfig.am \
    build-aux/vapi.am \
    build-aux/maia.am \
    build-aux/test.am \
    build-aux/generate-binding.am \
    build-aux/compile-binding.am \
    build-aux/doc-reference.am \
    build-aux/ac-define-dir.m4

TOOLS_FILES = \
    tools/generate-xcb-key-convert \
    tools/generate-xcb-keysym-vapi \
    tools/generate-keysym-enum

EXTRA_DIST = \
    $(maiadoc_DATA) \
    $(BUILD_FILES) \
    $(TOOLS_FILES)

if USE_BOOTSTRAP
EXTRA_DIST += \
    $(top_srcdir)/bootstrap.sh \
    $(top_srcdir)/bootstrap/vala-*.tar.xz \
    $(top_srcdir)/bootstrap/libgee-*.tar.xz \
    $(top_srcdir)/bootstrap/valadoc-*.tar.xz \
    $(top_srcdir)/bootstrap/libxcb-*.tar.gz \
    $(top_srcdir)/bootstrap/xcb-proto-*.tar.gz
endif

DISTCLEANFILES = \
    intltool-extract \
    intltool-merge \
    intltool-update \
    po/.intltool-merge-cache

ACLOCAL_AMFLAGS = -I build-aux

uninstall-local:
	-rm -rf $(maiadocdir)

dist-hook: gen-ChangeLog
	for specfile in *.spec; do \
        if test -f $$specfile; then \
            cp -p $$specfile $(distdir); \
        fi \
    done

.PHONY: gen-ChangeLog
gen-ChangeLog:
	if test -d .git; then                                    \
        $(top_srcdir)/gitlog-to-changelog > $(distdir)/cl-t; \
        rm -f $(distdir)/ChangeLog;                          \
        mv $(distdir)/cl-t $(distdir)/ChangeLog;             \
    fi

distcheck-hook:
if USE_BOOTSTRAP
	chmod +w $(distdir)/bootstrap && $(distdir)/bootstrap.sh build
endif

DISTCHECK_CONFIGURE_FLAGS = --enable-doc
