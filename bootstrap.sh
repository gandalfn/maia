#!/bin/bash

set -e

XCB_VERSION=1.12

function build
{
    if [ ! -e vala ];
    then
        if [ ! -e vala ];
        then
            git clone git://git.gnome.org/vala
        fi

        cd vala
        #git checkout staging
        ./autogen.sh --prefix=$PWD/../build --disable-shared --enable-static --disable-vapigen
        make -j8
        make install
        make clean

        rm -f */*.vala.stamp
        patch -p1 < ../base-set-property.patch
        patch -p1 < ../add-explicit-notify.patch
        ./configure \
            CFLAGS="-fPIC" \
            VALAC=$PWD/../build/bin/valac \
            --prefix=$PWD/../build --disable-shared --enable-static
        make -j8
        make install
        cd ..
    fi

    if [ ! -e libgee ];
    then
        if [ ! -e libgee ];
        then
            git clone git://git.gnome.org/libgee
        fi

        cd libgee
	patch -p1 < ../disable-ax-required.patch
        ./autogen.sh \
            CFLAGS="-fPIC" \
            VALAC=$PWD/../build/bin/valac \
            --prefix=$PWD/../build --disable-shared --enable-static --enable-introspection=no
        make -j8
        make install
        cd ..
    fi

    if [ ! -e valadoc ];
    then
        if [ ! -e valadoc ];
        then
            git clone git://git.gnome.org/valadoc
        fi

        cd valadoc
        export PKG_CONFIG_PATH=$PWD/../build/lib/pkgconfig
        export LD_LIBRARY_PATH="$PWD/../build/lib"
        ./autogen.sh CFLAGS="-I$PWD/../build/include -fPIC" \
            VALAC="$PWD/../build/bin/valac --vapidir $PWD/../build/share/vala/vapi" \
            --prefix=$PWD/../build
        make -j8
        make install
        cd ..
    fi

    if [ ! -e xcb-proto-${XCB_VERSION} ];
    then
        if [ ! -e xcb-proto-${XCB_VERSION}.tar.gz ];
        then
            wget --no-check-certificate https://xcb.freedesktop.org/dist/xcb-proto-${XCB_VERSION}.tar.gz
        fi
        tar xvf xcb-proto-${XCB_VERSION}.tar.gz

        cd xcb-proto-${XCB_VERSION}
        ./configure --prefix=$PWD/../build
        make -j8
        make install
        cd ..
    fi

    if [ ! -e libxcb-${XCB_VERSION} ];
    then
        if [ ! -e libxcb-${XCB_VERSION}.tar.gz ];
        then
            wget --no-check-certificate https://xcb.freedesktop.org/dist/libxcb-${XCB_VERSION}.tar.gz
        fi
        tar xvf libxcb-${XCB_VERSION}.tar.gz

        cd libxcb-${XCB_VERSION}
        export PKG_CONFIG_PATH=$PWD/../build/lib/pkgconfig
        ./configure \
            CFLAGS="-fPIC" \
            --prefix=$PWD/../build --disable-shared --enable-static --enable-xinput --without-doxygen
        make -j8
        make install
        cd ..
    fi
}

function clean
{
    rm -rf vala
    rm -rf libgee
    rm -rf valadoc
    rm -rf xcb-proto-${XCB_VERSION}*
    rm -rf libxcb-${XCB_VERSION}*
    rm -rf build
}

if [ $# -lt 1 ]
then
    echo "$0 [COMMAND]"
    echo "COMMAND:"
    echo "  - build : build bootstrap"
    echo "  - clean : clean bootstrap"
    exit 1
fi

cd bootstrap

if [ $1 == "build" ];
then
    build
elif [ $1 == "clean" ];
then
    clean
fi
