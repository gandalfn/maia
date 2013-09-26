m4_define(maia_version_major, 0)
m4_define(maia_version_minor, 1)
m4_define(maia_version_micro, 10)
AC_INIT([maia],[maia_version_major.maia_version_minor.maia_version_micro])
AC_PREREQ(2.63)

dnl ****************************************************************************
dnl Define default build directory
dnl ****************************************************************************
AC_CONFIG_SRCDIR(lib/maia.pc.in)
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([build-aux])
AC_CONFIG_HEADERS(build-aux/config.h)

dnl ******************************************
**********************************
dnl Init automake
dnl ****************************************************************************
AM_INIT_AUTOMAKE([1.11 dist-bzip2 silent-rules])
m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])])
AC_ARG_VAR([ACLOCAL_FLAGS], [aclocal flags, e.g. -I <macro dir>])
AM_MAINTAINER_MODE

dnl ****************************************************************************
dnl Define version
dnl ****************************************************************************
MAIA_MAJOR_VERSION=maia_version_major
MAIA_MINOR_VERSION=maia_version_minor
MAIA_MICRO_VERSION=maia_version_micro
MAIA_SO_VERSION="maia_version_major:maia_version_minor:maia_version_micro"
MAIA_ABI=$MAIA_MAJOR_VERSION.$MAIA_MINOR_VERSION
MAIA_VERSION=$MAIA_MAJOR_VERSION.$MAIA_MINOR_VERSION.$MAIA_MICRO_VERSION

AC_DEFINE_UNQUOTED(MAIA_MAJOR_VERSION, $MAIA_MAJOR_VERSION, [Major version])
AC_DEFINE_UNQUOTED(MAIA_MINOR_VERSION, $MAIA_MINOR_VERSION, [Minor version])
AC_DEFINE_UNQUOTED(MAIA_MICRO_VERSION, $MAIA_MICRO_VERSION, [Micro version])
AC_DEFINE_UNQUOTED(MAIA_ABI, $MAIA_VERSION, [Version])
AC_DEFINE_UNQUOTED(MAIA_VERSION, $MAIA_VERSION, [Version])
AC_SUBST(MAIA_VERSION)
AC_SUBST(MAIA_ABI)
AC_SUBST(MAIA_SO_VERSION)

dnl ****************************************************************************
dnl Packages version required
dnl ****************************************************************************
GLIB_REQUIRED=2.32.0
VALA_REQUIRED=0.20.0
PIXMAN_REQUIRED=0.16.4
CAIRO_REQUIRED=1.10.2
PANGO_REQUIRED=1.30.0
RSVG_REQUIRES=2.36.1
GDK_PIXBUF_REQUIRED=2.26.0
GTK_REQUIRED=2.24.0
GTKSOURCEVIEW_REQUIRED=2.10.0
GLIBMM_REQUIRED=2.32.0
GTKMM_REQUIRED=2.24.0
AC_SUBST(GLIB_REQUIRED)
AC_SUBST(CAIRO_REQUIRED)
AC_SUBST(PANGO_REQUIRED)
AC_SUBST(GDK_PIXBUF_REQUIRED)
AC_SUBST(GTK_REQUIRED)
AC_SUBST(RSVG_REQUIRED)
AC_SUBST(GLIBMM_REQUIRED)
AC_SUBST(GTKMM_REQUIRED)

dnl ****************************************************************************
dnl Check for build
dnl ****************************************************************************
AC_SEARCH_LIBS([strerror],[cposix])
AC_PROG_CC
AC_PROG_CXX
AC_LANG([C])
AC_LANG([C++])

dnl ****************************************************************************
dnl Check for libtool
dnl ****************************************************************************
LT_PREREQ([2.2])
LT_INIT([disable-static pic-only])

dnl ****************************************************************************
dnl Check for mm-common
dnl ****************************************************************************
MM_PREREQ([0.9])
MM_INIT_MODULE([maiamm])

dnl ****************************************************************************
dnl Check for packages
dnl ****************************************************************************
PKG_CHECK_MODULES(MAIA, [glib-2.0 >= $GLIB_REQUIRED
                         gio-2.0 >= $GLIB_REQUIRED
                         gobject-2.0 >= $GLIB_REQUIRED
                         gmodule-2.0 >= $GLIB_REQUIRED
                         xproto])
AC_SUBST(MAIA_CFLAGS)
AC_SUBST(MAIA_LIBS)

AC_SUBST([MAIAMM_MODULES], ['glibmm-2.4'])
PKG_CHECK_MODULES([MAIAMM], [$MAIAMM_MODULES])
AC_SUBST(MAIAMM_CFLAGS)
AC_SUBST(MAIAMM_LIBS)

dnl ****************************************************************************
dnl Check for cairo packages
dnl ****************************************************************************
PKG_CHECK_MODULES(MAIA_CAIRO, [cairo >= $CAIRO_REQUIRED
                               pango >= $PANGO_REQUIRED
                               pangocairo >= $PANGO_REQUIRED])
AC_SUBST(MAIA_CAIRO_CFLAGS)
AC_SUBST(MAIA_CAIRO_LIBS)

AC_SUBST([MAIA_CAIROMM_MODULES], ['giomm-2.4 pangomm-1.4 cairomm-1.0'])
PKG_CHECK_MODULES([MAIA_CAIROMM], [$MAIA_CAIROMM_MODULES])
AC_SUBST(MAIA_CAIROMM_CFLAGS)
AC_SUBST(MAIA_CAIROMM_LIBS)

dnl ****************************************************************************
dnl Check for rsvg packages
dnl ****************************************************************************
PKG_CHECK_MODULES(MAIA_RSVG, [cairo >= $CAIRO_REQUIRED
                              librsvg-2.0 >= $RSVG_REQUIRES])
AC_SUBST(MAIA_RSVG_CFLAGS)
AC_SUBST(MAIA_RSVG_LIBS)
MAIA_RSVG_VERSION=$(pkg-config --modversion librsvg-2.0  | awk -F "." '{print "LIBRSVG_"$1"_"$2"_"$3;}')
AC_SUBST(MAIA_RSVG_VERSION)

dnl ****************************************************************************
dnl Check for gdk-pixbuf packages
dnl ****************************************************************************
PKG_CHECK_MODULES(MAIA_GDK_PIXBUF, [gdk-pixbuf-2.0 >= $GDK_PIXBUF_REQUIRED])
AC_SUBST(MAIA_GDK_PIXBUF_CFLAGS)
AC_SUBST(MAIA_GDK_PIXBUF_LIBS)

dnl ****************************************************************************
dnl Check for gtk packages
dnl ****************************************************************************
PKG_CHECK_MODULES(MAIA_GTK, [gtk+-2.0 >= $GTK_REQUIRED])
AC_SUBST(MAIA_GTK_CFLAGS)
AC_SUBST(MAIA_GTK_LIBS)

AC_SUBST([MAIA_GTKMM_MODULES], ['gtkmm-2.4'])
PKG_CHECK_MODULES([MAIA_GTKMM], [$MAIA_GTKMM_MODULES])
AC_SUBST(MAIA_GTKMM_CFLAGS)
AC_SUBST(MAIA_GTKMM_LIBS)

dnl ****************************************************************************
dnl Check for canvas-editor packages
dnl ****************************************************************************
PKG_CHECK_MODULES(MAIA_CANVAS_EDITOR, [gtksourceview-2.0 >= $GTKSOURCEVIEW_REQUIRED])
AC_SUBST(MAIA_CANVAS_EDITOR_CFLAGS)
AC_SUBST(MAIA_CANVAS_EDITOR_LIBS)

dnl ***************************************************************************
dnl check for valgrind
dnl ***************************************************************************
AC_ARG_ENABLE(valgrind,
  AS_HELP_STRING([--enable-valgrind],
                 [Enable valgrind support]),
  [use_valgrind=$enableval], [use_valgrind=no])

if test "x$use_valgrind" = "xyes"; then
    PKG_CHECK_MODULES(MAIA_VALGRIND, [valgrind])
    AC_SUBST(MAIA_VALGRIND_CFLAGS)
    AC_SUBST(MAIA_VALGRIND_LIBS)
fi

AM_CONDITIONAL(USE_VALGRIND, test "x$use_valgrind" = "xyes")

dnl ***************************************************************************
dnl check for log
dnl ***************************************************************************
AC_ARG_ENABLE(log,
  [  --enable-log        Enable log message],
  [log=$enableval], [log=no])

if test x"$log" = xyes; then
    MAIA_CFLAGS="$MAIA_CFLAGS -DMAIA_ENABLE_LOG"

    AC_SEARCH_LIBS(backtrace_symbols, [execinfo])
    AC_CHECK_FUNCS(backtrace_symbols)

    AC_ARG_ENABLE(enhanced-debug,
      [  --enable-enhanced-debug        Enable enhanced debug message],
      [enhanced_debug=$enableval], [enhanced_debug=no])

    if test x"$enhanced_debug" = xyes; then
        AC_CHECK_LIB(bfd, main, [BFD_LIBS="-lbfd"], [])
        AC_CHECK_LIB(iberty, main, [IBERTY_LIBS="-liberty"], [])
        ENHANCED_DEBUG_LIBS="$BFD_LIBS $IBERTY_LIBS"
        MAIA_LIBS="$MAIA_LIBS $ENHANCED_DEBUG_LIBS"
        if test "$ENHANCED_DEBUG_LIBS" = "-lbfd -liberty"; then
            AC_DEFINE(HAVE_ENHANCED_DEBUG, 1, [Enhanced debug enabled])
        fi
    fi
fi

dnl ****************************************************************************
dnl Check for vala
dnl ****************************************************************************
AM_PROG_VALAC($VALA_REQUIRED)
VALA_VAPI_PATH=$($PKG_CONFIG --variable=vapidir libvala-0.20)
AC_SUBST(VALA_VAPI_PATH)

dnl ****************************************************************************
dnl Check for valadoc
dnl ****************************************************************************
AC_ARG_ENABLE(doc,
  AS_HELP_STRING([--enable-doc],
                 [Enable documentation generation]),
  [enabledoc=$enableval], [enabledoc=no])

found_valadoc=no
if test "x$enabledoc" = "xyes"; then
    AS_IF([test "x$enable_valadoc" != "xno"], [
        AC_PATH_PROG(VALADOC, valadoc, :)
        AS_IF([test -x "$VALADOC"], [
          found_valadoc=yes
          AC_SUBST(VALADOC)
        ], [
          AS_IF([test "x$enable_valadoc" == "xyes"], AC_MSG_ERROR([Unable to find valadoc]))
        ])
      ])
    PKG_CHECK_MODULES(MAIA_VALADOC, [valadoc-1.0])
    AC_SUBST(MAIA_VALADOC_CFLAGS)
    AC_SUBST(MAIA_VALADOC_LIBS)
fi
AM_CONDITIONAL(ENABLE_VALADOC, test x$found_valadoc = xyes)

dnl ****************************************************************************
dnl Define path
dnl ****************************************************************************
vapidir=${datadir}/vala/vapi
uidir=${datadir}/maia/ui
sourceviewdir=${datadir}/gtksourceview-2.0/language-specs
AC_DEFINE_DIR([MAIA_UI_PATH], [uidir], [ui path])
AC_SUBST(vapidir)
AC_SUBST(uidir)
AC_SUBST(sourceviewdir)


dnl ****************************************************************************
dnl Check for mm-common
dnl ****************************************************************************
MM_PKG_CONFIG_SUBST([GTHREAD_CFLAGS], [--cflags-only-other gthread-2.0])
MM_PKG_CONFIG_SUBST([GMMPROC_DIR], [--variable=gmmprocdir glibmm-2.4])
MM_PKG_CONFIG_SUBST([GMMPROC_EXTRA_M4_DIR], [--variable=gmmprocm4dir pangomm-1.4 atkmm-1.6 gtkmm-2.4])

MM_ARG_ENABLE_WARNINGS([MAIAMM_WXXFLAGS],
                       [-Wall],
                       [-pedantic -Wall -Wextra],
                       [G SKELETON])

dnl ****************************************************************************
dnl Check for build docs
dnl ****************************************************************************
MMDOCTOOLDIR=/usr/share/mm-common/doctool
MM_ARG_ENABLE_DOCUMENTATION

dnl ****************************************************************************
dnl Generate outputs
dnl ****************************************************************************
AC_CONFIG_FILES([
Makefile
lib/maia.pc
lib/Makefile
lib/cairo/maia-cairo-graphic.pc
lib/cairo/Makefile
lib/rsvg/maia-rsvg.pc
lib/rsvg/Makefile
lib/gdk-pixbuf/maia-gdk-pixbuf.pc
lib/gdk-pixbuf/Makefile
lib/gtk/maia-gtk.pc
lib/gtk/Makefile
doc/Makefile
cpp/maiamm.pc
cpp/Makefile
cpp/codegen/Makefile
cpp/src/Makefile
cpp/maiamm/Makefile
cpp/gtk/maia-gtkmm.pc
cpp/gtk/Makefile
cpp/gtk/src/Makefile
cpp/gtk/maia-gtkmm/Makefile
cpp/cairo/maia-cairo-graphicmm.pc
cpp/cairo/Makefile
cpp/cairo/src/Makefile
cpp/cairo/maia-cairo-graphicmm/Makefile
cpp/doc/Makefile
cpp/doc/reference/Doxyfile
tools/Makefile
test/Makefile
vapi/Makefile])

AC_OUTPUT
