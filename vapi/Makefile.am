include $(top_srcdir)/build/maia.am

maia-0.1.vapi: object.vapi source.vapi ${top_builddir}/src/maia.vapi
	@cat object.vapi source.vapi ${top_builddir}/src/maia.vapi > maia-0.1.vapi

vapi_DATA = \
    maia-0.1.vapi

noinst_DATA = \
    config.vapi \
    object.vapi \
    source.vapi

EXTRA_DIST = \
    $(vapi_DATA) \
    $(noinst_DATA)

CLEANFILES = \
    $(vapi_DATA)