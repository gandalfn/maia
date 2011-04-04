m4_define(maia_version_major, 0)
m4_define(maia_version_minor, 1)
m4_define(maia_version_micro, 0)
AC_INIT([maia], [maia_version_major.maia_version_minor.maia_version_micro], [gandalfn@club-internet.fr], [maia], [http://gitorious.org/maia])
AC_PREREQ(2.63)

dnl ****************************************************************************
dnl Define default build directory
dnl ****************************************************************************
AC_CONFIG_SRCDIR(lib/maia.pc.in)
AC_CONFIG_AUX_DIR([build])
AC_CONFIG_MACRO_DIR([build])
AC_CONFIG_HEADERS(build/config.h)

dnl ****************************************************************************
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
dnl Internationalization
dnl ****************************************************************************
GETTEXT_PACKAGE=AC_PACKAGE_NAME
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE, "$GETTEXT_PACKAGE", [The gettext translation domain])
IT_PROG_INTLTOOL([0.40.1])
AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.17])

dnl ****************************************************************************
dnl Packages version required
dnl ****************************************************************************
GLIB_REQUIRED=2.24.0
VALA_REQUIRED=0.12.0
PIXMAN_REQUIRED=0.16.4

dnl ****************************************************************************
dnl Check for build
dnl ****************************************************************************
AC_LANG([C])
AM_PROG_CC_C_O
AC_SEARCH_LIBS([strerror],[cposix])

dnl ****************************************************************************
dnl Check for libtool
dnl ****************************************************************************
LT_PREREQ([2.2])
LT_INIT([disable-static])

dnl ****************************************************************************
dnl Check for packages
dnl ****************************************************************************
PKG_CHECK_MODULES(MAIA, [glib-2.0 >= $GLIB_REQUIRED
                         gobject-2.0 >= $GLIB_REQUIRED
                         gmodule-2.0 >= $GLIB_REQUIRED
                         pixman-1 >= $PIXMAN_REQUIRED
                         xcb])
AC_SUBST(MAIA_CFLAGS)
AC_SUBST(MAIA_LIBS)

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
VALA_VAPI_PATH=$($PKG_CONFIG --variable=vapidir libvala-0.14)
AC_SUBST(VALA_VAPI_PATH)

dnl ****************************************************************************
dnl Generate outputs
dnl ****************************************************************************
AC_CONFIG_FILES([
Makefile
lib/maia.pc
lib/Makefile
lib/core/maia-core.pc
lib/core/Makefile
lib/xml/maia-xml.pc
lib/xml/Makefile
lib/graphic/maia-graphic.pc
lib/graphic/Makefile
lib/xcb/maia-xcb-backend.pc
lib/xcb/Makefile
test/Makefile
vapi/Makefile
po/Makefile.in])

AC_OUTPUT
