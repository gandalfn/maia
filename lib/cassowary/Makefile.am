includelibdir = $(includedir)/cassowary

MAIA_LIB_NAME = maia-cassowary

MAIA_VAPI_DEPS = \
    core/maia-core

include $(top_srcdir)/build/maia.am
include $(top_srcdir)/build/pkgconfig.am
include $(top_srcdir)/build/vapi.am

lib_LTLIBRARIES = libmaia-cassowary.la

libmaia_cassowary_la_SOURCES = \
	cassowary.vala \
    abstract-variable.vala \
    variable.vala \
    dummy-variable.vala \
    objective-variable.vala \
    slack-variable.vala \
    symbolic-weight.vala \
    strength.vala \
    double.vala \
    linear-expression.vala \
    tableau.vala \
    constraint.vala \
    linear-constraint.vala \
    edit-or-stay-constraint.vala \
    edit-constraint.vala \
    stay-constraint.vala \
    linear-inequality.vala \
    linear-equation.vala \
    edit-info.vala \
    point.vala \
    simplex-solver.vala

libmaia_cassowary_la_LDFLAGS = \
    -version-number @MAIA_SO_VERSION@ \
    -no-undefined

libmaia_cassowary_la_LIBADD = \
    $(MAIA_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_cassowary_la_SOURCES))

CLEANFILES += \
    libmaia_cassowary_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    $(pkgconfig_DATA)
