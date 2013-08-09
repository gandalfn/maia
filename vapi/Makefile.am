include $(top_srcdir)/build-aux/maia.am

gdk-keysym.vapi:
	@$(AM_V_GEN) $(top_srcdir)/tools/generate-gdk-keysym-vapi > $@

noinst_DATA = \
    config.vapi \
    os.vapi \
    cairo.vapi \
    valgrind.vapi \
    gdk-keysym.vapi

EXTRA_DIST += \
    $(noinst_DATA)

CLEANFILES += \
    gdk-keysym.vapi
