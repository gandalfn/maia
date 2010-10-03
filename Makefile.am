SUBDIRS = src test vapi po

maiadocdir = ${prefix}/doc/maia
maiadoc_DATA = \
    README\
    COPYING\
    AUTHORS\
    ChangeLog\
    INSTALL\
    NEWS

BUILD_FILES = \
    build/common.am \
    build/pkgconfig.am \
    build/vapi.am \
    build/maia.am

INTLTOOL_FILES = \
    intltool-extract.in \
    intltool-merge.in \
    intltool-update.in

EXTRA_DIST = \
    $(maiadoc_DATA) \
    $(INTLTOOL_FILES) \
    $(BUILD_FILES)

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
