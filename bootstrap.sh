#!/bin/bash

VALA_VERSION=0.32.1
VALA_ABI=$(echo ${VALA_VERSION} | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\)/\1\.\2/')
XCB_VERSION=1.12

function build
{
    if [ ! -e vala-${VALA_VERSION} ];
    then
        if [ ! -e vala-${VALA_VERSION}.tar.xz ];
        then
            wget ftp://ftp.gnome.org/pub/gnome/sources/vala/${VALA_ABI}/vala-${VALA_VERSION}.tar.xz
        fi
        tar xvf vala-${VALA_VERSION}.tar.xz
        cd vala-${VALA_VERSION}
        patch -p1 < ../base-set-property.patch
        cd ..
    fi

    cd vala-${VALA_VERSION}
    ./configure --prefix=$PWD/../build --disable-shared --enable-static
    make
    make install
    cd ..

    if [ ! -e xcb-proto-${XCB_VERSION} ];
    then
        if [ ! -e xcb-proto-${XCB_VERSION}.tar.gz ];
        then
            wget --no-check-certificate https://xcb.freedesktop.org/dist/xcb-proto-${XCB_VERSION}.tar.gz
        fi
        tar xvf xcb-proto-${XCB_VERSION}.tar.gz
    fi

    cd xcb-proto-${XCB_VERSION}
    ./configure --prefix=$PWD/../build
    make
    make install
    cd ..

    if [ ! -e libxcb-${XCB_VERSION} ];
    then
        if [ ! -e libxcb-${XCB_VERSION}.tar.gz ];
        then
            wget --no-check-certificate https://xcb.freedesktop.org/dist/libxcb-${XCB_VERSION}.tar.gz
        fi
        tar xvf libxcb-${XCB_VERSION}.tar.gz
    fi

    cd libxcb-${XCB_VERSION}
    PKG_CONFIG_PATH=$PWD/../build/lib/pkgconfig CFLAGS="-fPIC" ./configure --prefix=$PWD/../build --disable-shared --enable-static --enable-xinput --without-doxygen
    make
    make install
    cd ..
}

function clean
{
    rm -rf vala-${VALA_VERSION}*
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
