include $(top_srcdir)/build-aux/maia.am

xcb-keysym.vapi:
	@$(AM_V_GEN) $(top_srcdir)/tools/generate-xcb-keysym-vapi > $@

noinst_DATA = \
    config.vapi \
    os.vapi \
    x11.vapi \
    x11-xcb.vapi \
    xcb-base.deps \
    xcb-base.vapi \
    xcb.deps \
    xcb.vapi \
    xcb-composite.deps \
    xcb-composite.vapi \
    xcb-glx.deps \
    xcb-glx.vapi \
    xcb-randr.deps \
    xcb-randr.vapi \
    xcb-render.deps \
    xcb-render.vapi \
    xcb-render-util.deps \
    xcb-render-util.vapi \
    xcb-shape.deps \
    xcb-shape.vapi \
    xcb-xfixes.deps \
    xcb-xfixes.vapi \
    xcb-keysym.vapi \
    xcb-keysyms.vapi \
    xcb-cursor.vapi \
    xcb-cursorfont.vapi \
    gl.vapi \
    glx.vapi \
    cairo.vapi \
    cairo-xcb.vapi \
    valgrind.vapi \
    gtk+-2.0.vapi \
    gtk+-2.0.deps \
    libintl.vapi \
    uuid.vapi \
    gvalue-collect.vapi \
    librsvg-2.36.1.vapi \
    librsvg-2.36.1.deps

EXTRA_DIST += \
    $(noinst_DATA)

CLEANFILES += \
    xcb-keysym.vapi
