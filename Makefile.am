SUBDIRS = vapi lib test doc

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
    build-aux/pkgconfig.am \
    build-aux/vapi.am \
    build-aux/maia.am

TOOLS_FILES = \
    tools/generate-gdk-key-convert \
    tools/generate-gdk-keysym-vapi \
    tools/generate-keysym-enum

EXTRA_DIST = \
    $(maiadoc_DATA) \
    $(BUILD_FILES) \
    $(TOOLS_FILES)

DISTCLEANFILES = \
    intltool-extract \
    intltool-merge \
    intltool-update \
    po/.intltool-merge-cache

uninstall-local:
	-rm -r $(maiadocdir)

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
