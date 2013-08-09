#! /bin/sh -e
test -n "$srcdir" || srcdir=`dirname "$0"`
test -n "$srcdir" || srcdir=.

autoreconf --force --install --warnings=none "$srcdir"
test -n "$NOCONFIGURE" || "$srcdir/configure" --enable-maintainer-mode "$@"
