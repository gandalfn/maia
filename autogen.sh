#! /bin/sh -e
test -n "$srcdir" || srcdir=`dirname "$0"`
test -n "$srcdir" || srcdir=.

mm-common-prepare --copy --force "$srcdir"
autoreconf --force --install --warnings=none "$srcdir"
if [ -e /usr/bin/ccache ]
then
    echo "  using ccache"
    export CC="ccache gcc"
    export CXX="ccache g++"
fi
test -n "$NOCONFIGURE" || "$srcdir/configure" --enable-maintainer-mode "$@"
