#!/bin/bash

set -e

XCB_VERSION=1.12

function checkout
{
    if [ ! -e vala.tar.xz ]
    then
        git clone git://git.gnome.org/vala
        cd vala
        ./autogen.sh --prefix=$PWD/../build --disable-shared --enable-static --disable-vapigen
        make -j8
        make clean
        rm -f */*.vala.stamp
        cd ..
        tar jcvf vala.tar.xz --exclude .git vala
        rm -rf vala
    fi
    if [ ! -e libgee.tar.xz ]
    then
        git clone --depth=1 git://git.gnome.org/libgee
        tar jcvf libgee.tar.xz --exclude .git  libgee
        rm -rf libgee
    fi
    if [ ! -e valadoc.tar.xz ]
    then
        git clone --depth=1 git://git.gnome.org/valadoc
        tar jcvf valadoc.tar.xz --exclude .git  valadoc
        rm -rf valadoc
    fi
    if [ ! -e xcb-proto-${XCB_VERSION}.tar.gz ];
    then
        wget --no-check-certificate https://xcb.freedesktop.org/dist/xcb-proto-${XCB_VERSION}.tar.gz
    fi
    if [ ! -e libxcb-${XCB_VERSION}.tar.gz ];
    then
        wget --no-check-certificate https://xcb.freedesktop.org/dist/libxcb-${XCB_VERSION}.tar.gz
    fi
}

function build
{
    if [ ! -e vala-build.stamp ];
    then
        if [ -e vala ]
        then
            rm -rf vala
        fi
        tar xvf vala.tar.xz
        cd vala
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
        rm -rf vala
        touch vala-build.stamp
    fi


    if [ ! -e libgee-build.stamp ];
    then
        if [ -e libgee ]
        then
            rm -rf libgee
        fi
        tar xvf libgee.tar.xz
        cd libgee
        patch -p1 < ../disable-ax-required.patch
        ./autogen.sh \
            CFLAGS="-fPIC" \
            VALAC=$PWD/../build/bin/valac \
            --prefix=$PWD/../build --disable-shared --enable-static --enable-introspection=no
        make -j8
        make install
        cd ..
        rm -rf libgee
        touch libgee-build.stamp
    fi

    if [ ! -e valadoc-build.stamp ];
    then
        if [ -e valadoc ]
        then
            rm -rf valadoc
        fi
        tar xvf valadoc.tar.xz
        cd valadoc
        patch -p1 < ../fix-valadoc-gen.patch
        export PKG_CONFIG_PATH=$PWD/../build/lib/pkgconfig
        export LD_LIBRARY_PATH="$PWD/../build/lib"
        ./autogen.sh CFLAGS="-I$PWD/../build/include -fPIC" \
            VALAC="$PWD/../build/bin/valac --vapidir $PWD/../build/share/vala/vapi" \
            --prefix=$PWD/../build
        make -j8
        make install
        cd ..
        rm -rf valadoc
        touch valadoc-build.stamp
    fi

    if [ ! -e xcb-proto-${XCB_VERSION}-build.stamp ];
    then
        if [ -e xcb-proto-${XCB_VERSION} ];
        then
            rm -rf xcb-proto-${XCB_VERSION}
        fi
        tar xvf xcb-proto-${XCB_VERSION}.tar.gz

        cd xcb-proto-${XCB_VERSION}
        ./configure --prefix=$PWD/../build
        make -j8
        make install
        cd ..
        rm -rf xcb-proto-${XCB_VERSION}
        touch xcb-proto-${XCB_VERSION}-build.stamp
    fi

    if [ ! -e libxcb-${XCB_VERSION}-build.stamp ];
    then
        if [ -e libxcb-${XCB_VERSION} ];
        then
            rm -rf libxcb-${XCB_VERSION}
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
        rm -rf libxcb-${XCB_VERSION}
        touch libxcb-${XCB_VERSION}-build.stamp
    fi
}

function clean
{
    rm -f vala-build.stamp
    rm -rf vala
    rm -f libgee-build.stamp
    rm -rf libgee
    rm -f valadoc-build.stamp
    rm -rf valadoc
    rm -f xcb-proto-${XCB_VERSION}-build.stamp
    rm -rf xcb-proto-${XCB_VERSION}
    rm -f libxcb-${XCB_VERSION}-build.stamp
    rm -rf libxcb-${XCB_VERSION}
    rm -rf build
}

function mrproper
{
    clean
    rm -f vala.tar.xz
    rm -f libgee.tar.xz
    rm -f valadoc.tar.xz
    rm -f xcb-proto-${XCB_VERSION}.tar.gz
    rm -f libxcb-${XCB_VERSION}.tar.gz
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

if [ $1 == "checkout" ];
then
    checkout
elif [ $1 == "build" ];
then
    checkout
    build
elif [ $1 == "clean" ];
then
    clean
elif [ $1 == "mrproper" ];
then
    mrproper
fi
