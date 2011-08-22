MAIA_VAPI_DEPS = \
    $(top_builddir)/lib/maia-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/core/maia-core-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/xml/maia-xml-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/graphic/maia-graphic-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/cairo/maia-cairo-graphic-$(MAIA_ABI).vapi \
    $(top_builddir)/lib/xcb/maia-xcb-backend-$(MAIA_ABI).vapi

include $(top_srcdir)/build/maia.am

noinst_PROGRAMS = \
    test \
    test-window \
    test-token \
    test-atomic-list
    
test_SOURCES = \
    test.vala \
    test-case.vala \
    core/test-core.vala \
    core/test-atom.vala \
    core/test-spinlock.vala \
    core/test-array.vala \
    core/test-list.vala \
    core/test-set.vala \
    core/test-map.vala \
    core/test-object.vala \
    core/test-dispatcher.vala \
    core/test-application.vala \
    core/test-event.vala \
    core/test-notification.vala \
    xml/test-xml.vala \
    xml/test-parser.vala

test_LDADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/lib/libmaia.la \
    ${top_builddir}/lib/core/libmaia-core.la \
    ${top_builddir}/lib/xml/libmaia-xml.la \
    ${top_builddir}/lib/xcb/libmaia-xcb-backend.la

test_window_SOURCES = \
    test-window.vala

test_window_LDADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/lib/libmaia.la \
    ${top_builddir}/lib/core/libmaia-core.la \
    ${top_builddir}/lib/xml/libmaia-xml.la \
    ${top_builddir}/lib/graphic/libmaia-graphic.la \
    ${top_builddir}/lib/cairo/libmaia-cairo-graphic.la \
    ${top_builddir}/lib/xcb/libmaia-xcb-backend.la

test_thread_SOURCES = \
    test-thread.vala

test_thread_LDADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/lib/core/libmaia-core.la

test_atomic_list_SOURCES = \
    test-atomic-list.vala

test_atomic_list_LDADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/lib/core/libmaia-core.la

test_token_SOURCES = \
    test-token.vala

test_token_LDADD = \
    $(MAIA_LIBS) \
    ${top_builddir}/lib/core/libmaia-core.la

VALAFILES = \
    $(filter %.vala,$(test_SOURCES)) \
    $(filter %.vala,$(test_window_SOURCES)) \
    $(filter %.vala,$(test_atomic_list_SOURCES)) \
    $(filter %.vala,$(test_thread_SOURCES)) \
    $(filter %.vala,$(test_token_SOURCES))

CLEANFILES += \
    test_vala.stamp \
    $(VALAFILES:.vala=.c)
