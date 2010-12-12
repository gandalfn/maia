MAIA_LIB_NAME = maia-graphic

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

maia-graphic.h: libmaia_graphic_la_vala.stamp

lib_LTLIBRARIES = libmaia-graphic.la

includegraphicdir = $(includedir)/graphic

includegraphic_HEADERS = \
    maia-graphic.h

libmaia_graphic_la_VALAFLAGS = \
    --use-header \
    --header=maia-graphic.h \
    --library=maia-graphic

libmaia_graphic_la_SOURCES = \
    maia-graphic-context.vala

libmaia_graphic_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_graphic_la_LIBADD = \
    $(MAIA_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_graphic_la_SOURCES))

CLEANFILES += \
    maia-graphic.h \
    libmaia_graphic_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
