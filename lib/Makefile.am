MAIA_LIB_NAME = maia

MAIA_VAPI_DEPS = \
    core/maia-any

$(top_builddir)/lib/core/maia-any-$(MAIA_ABI).vapi: core/maia-any.vapi
	$(AM_V_GEN) cat $^ > $@

keysym.vala:
	$(AM_V_GEN) $(top_srcdir)/tools/generate-keysym-enum > $@

include $(top_srcdir)/build-aux/maia.am
include $(top_srcdir)/build-aux/pkgconfig.am
include $(top_srcdir)/build-aux/vapi.am

SUBDIRS = . cairo xcb rsvg gdk-pixbuf gtk

include_HEADERS += \
   core/maia-any.h

core/any.c: $(top_builddir)/lib/core/maia-any-$(MAIA_ABI).vapi maia.h

lib_LTLIBRARIES = libmaia.la

libmaia_la_SOURCES = \
    core/any.c \
    core/maia-any.h \
    core/logger.vala \
    core/functions.vala \
    core/iterator.vala \
    core/collection.vala \
    core/array.vala \
    core/queue.vala \
    core/stack.vala \
    core/async-queue.vala \
    core/list.vala \
    core/set.vala \
    core/pair.vala \
    core/map.vala \
    core/object.vala \
    core/parser.vala \
    core/source.vala \
    core/watch.vala \
    core/timeout.vala \
    core/timeout-interval.vala \
    core/timeout-pool.vala \
    core/timeline.vala \
    core/animator.vala \
    core/config.vala \
    core/extension.vala \
    core/extension-loader.vala \
    core/message.vala \
    core/bus.vala \
    core/bus-connection.vala \
    core/bus-service.vala \
    core/socket-watch.vala \
    core/socket-bus-connection.vala \
    core/socket-bus-service.vala \
    core/event.vala \
    core/event-args.vala \
    core/event-listener.vala \
    core/event-bus.vala \
    manifest/document.vala \
    manifest/element.vala \
    manifest/style.vala \
    manifest/attribute-scanner.vala \
    manifest/attribute.vala \
    manifest/attribute-bind.vala \
    manifest/function.vala \
    graphic/matrix.vala \
    graphic/transform.vala \
    graphic/point.vala \
    graphic/size.vala \
    graphic/rectangle.vala \
    graphic/region.vala \
    graphic/color.vala \
    graphic/gradient.vala \
    graphic/linear-gradient.vala \
    graphic/radial-gradient.vala \
    graphic/mesh-gradient.vala \
    graphic/path.vala \
    graphic/glyph.vala \
    graphic/context.vala \
    graphic/pattern.vala \
    graphic/surface.vala \
    graphic/image.vala \
    graphic/image-png.vala \
    graphic/image-jpg.vala \
    graphic/image-svg.vala \
    graphic/image-gif.vala \
    backend.vala \
    main.vala \
    keysym.vala \
    cursor.vala \
    scroll.vala \
    orientation.vala \
    drawable.vala \
    item.vala \
    item-packable.vala \
    item-movable.vala \
    item-resizable.vala \
    window.vala \
    group.vala \
    rectangle.vala \
    path.vala \
    image.vala \
    label.vala \
    entry.vala \
    grid.vala \
    button.vala \
    togglegroup.vala \
    togglebutton.vala \
    checkbutton.vala \
    highlight.vala \
    page.vala \
    document.vala \
    model.vala \
    view.vala \
    drawing-area.vala \
    shortcut.vala \
    popup.vala \
    combo.vala \
    tool.vala \
    toolbox.vala \
    arrow.vala \
    canvas.vala

libmaia_la_LDFLAGS = \
    -Wl,--as-needed \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_la_LIBADD = \
    $(MAIA_LIBS) -lm

VALAFILES = \
    $(filter %.vala,$(libmaia_la_SOURCES))

vapi_DATA += \
    $(top_builddir)/lib/core/maia-any-$(MAIA_ABI).vapi

CLEANFILES += \
    keysym.vala \
    libmaia_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA) \
    $(top_builddir)/lib/core/maia-any-$(MAIA_ABI).vapi

EXTRA_DIST += \
    core/maia-any.vapi \
    core/maia-any.h
