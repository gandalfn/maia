AUTOMAKE_OPTIONS = subdir-objects

include $(srcdir)/m4/filelist.am

dist_noinst_DATA = $(addprefix m4/,$(files_codegen_m4))

noinst_PROGRAMS  = \
    extradefs/generate_maia_defs

extradefs_generate_maia_defs_SOURCES = \
    extradefs/generate_defs_maia.cpp

extradefs_generate_maia_defs_LDADD   = \
    $(MAIA_LIBS) \
    $(MAIAMM_LIBS) \
    ${top_builddir}/lib/libmaia.la \
    -lglibmm_generate_extra_defs-2.4

AM_CPPFLAGS = \
    -I$(top_builddir) \
    -I${top_srcdir}/lib \
    -I${top_srcdir}/lib/core \
    $(GTHREAD_CFLAGS) \
    $(MAIA_CFLAGS) \
    $(MAIAMM_CFLAGS)

AM_CXXFLAGS = $(MAIAMM_WXXFLAGS)

EXTRA_DIST = \
    enum.pl \
    h2def/argtypes.py \
    h2def/codegen.py \
    h2def/createdefs.py \
    h2def/definitions.py \
    h2def/defsparser.py \
    h2def/docextract.py \
    h2def/docgen.py \
    h2def/h2def.py \
    h2def/__init__.py \
    h2def/mergedefs.py \
    h2def/mkskel.py \
    h2def/override.py \
    h2def/reversewrapper.py \
    h2def/scmexpr.py

.DELETE_ON_ERROR:
