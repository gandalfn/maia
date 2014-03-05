include $(top_srcdir)/build-aux/maia.am

gdk-keysym.vapi:
	@$(AM_V_GEN) $(top_srcdir)/tools/generate-gdk-keysym-vapi > $@

xcb-keysym.vapi:
	@$(AM_V_GEN) $(top_srcdir)/tools/generate-xcb-keysym-vapi > $@

noinst_DATA = \
    config.vapi \
    os.vapi \
    xcb-base.deps \
    xcb-base.vapi \
    xcb.deps \
    xcb.vapi \
    xcb-keysym.vapi \
    xcb-keysyms.vapi \
    cairo.vapi \
    cairo-xcb.vapi \
    valgrind.vapi \
    gdk-keysym.vapi \
    gtk+-2.0.vapi \
    gtk+-2.0.deps \
    libintl.vapi \
    uuid.vapi

EXTRA_DIST += \
    $(noinst_DATA)

CLEANFILES += \
    gdk-keysym.vapi \
    xcb-keysym.vapi
