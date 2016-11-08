#!/bin/bash

set -e

XCB_VERSION=1.12

function vala_version
{
    ls vala-*.tar.xz 2> /dev/null | sed -e 's/^vala-\(.*\).tar.xz/\1/'
}

function libgee_version
{
    ls libgee-*.tar.xz 2> /dev/null | sed -e 's/^libgee-\(.*\).tar.xz/\1/'
}

function valadoc_version
{
    ls valadoc-*.tar.xz 2> /dev/null | sed -e 's/^valadoc-\(.*\).tar.xz/\1/'
}

function checkout
{
    checkout_root_dir=
    if [ ! -e vala-$(vala_version).tar.xz ]
    then
        git clone git://git.gnome.org/vala
        cd vala
        ./autogen.sh --prefix=$(dirname $PWD)/checkout --disable-shared --enable-static
        make -j8
        make install
        make clean

        rm -f */*.vala.stamp
        patch -p1 < ../base-set-property.patch
        patch -p1 < ../add-explicit-notify.patch
        ./configure \
            CFLAGS="-fPIC" \
            VALAC=$(dirname $PWD)/checkout/bin/valac \
            --prefix=$(dirname $PWD)/checkout --disable-shared --enable-static
        make -j8
        make install
        make dist
        mv vala-*.tar.xz ..
        cd ..
        rm -rf vala
    fi
    if [ ! -e libgee-$(libgee_version).tar.xz ]
    then
        git clone git://git.gnome.org/libgee
        cd libgee
        patch -p1 < ../disable-ax-required.patch
        ./autogen.sh \
            CFLAGS="-fPIC" \
            VALAC=$(dirname $PWD)/checkout/bin/valac \
            --prefix=$(dirname $PWD)/checkout --disable-shared --enable-static --enable-introspection=no
        make -j8
        make install
        make dist
        mv libgee-*.tar.xz ..
        cd ..
        rm -rf libgee
    fi
    if [ ! -e valadoc-$(valadoc_version).tar.xz ]
    then
        git clone git://git.gnome.org/valadoc
        cd valadoc
        patch -p1 < ../fix-valadoc-gen.patch
        patch -p1 < ../fix-valadoc-pc.patch
        export PKG_CONFIG_PATH=$(dirname $PWD)/checkout/lib/pkgconfig
        export LD_LIBRARY_PATH="$(dirname $PWD)/checkout/lib"
        ./autogen.sh CFLAGS="-I$(dirname $PWD)/checkout/include -fPIC" \
            VALAC="$(dirname $PWD)/checkout/bin/valac --vapidir $(dirname $PWD)/checkout/share/vala/vapi" \
            --prefix=$(dirname $PWD)/checkout
        make -j8
        make dist
        mv valadoc-*.tar.xz ..
        cd ..
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

    if [ -e checkout ]
    then
        rm -rf checkout
    fi
}

function build
{
    if [ ! -e vala-build.stamp ];
    then
        if [ -e vala-$(vala_version) ]
        then
            rm -rf vala-$(vala_version)
        fi
        tar xvf vala-$(vala_version).tar.xz
        cd vala-$(vala_version)
        ./configure \
            CFLAGS="-fPIC" \
            --prefix=$(dirname $PWD)/build --disable-shared --enable-static
        make -j8
        make install
        cd ..
        rm -rf vala-$(vala_version)
        touch vala-build.stamp
    fi


    if [ ! -e libgee-build.stamp ];
    then
        if [ -e libgee-$(libgee_version) ]
        then
            rm -rf libgee-$(libgee_version)
        fi
        tar xvf libgee-$(libgee_version).tar.xz
        cd libgee-$(libgee_version)
        ./configure \
            CFLAGS="-fPIC" \
            VALAC=$(dirname $PWD)/build/bin/valac \
            --prefix=$(dirname $PWD)/build --disable-shared --enable-static --enable-introspection=no
        make -j8
        make install
        cd ..
        rm -rf libgee-$(libgee_version)
        touch libgee-build.stamp
    fi

    if [ ! -e valadoc-build.stamp ];
    then
        if [ -e valadoc-$(valadoc_version) ]
        then
            rm -rf valadoc-$(valadoc_version)
        fi
        tar xvf valadoc-$(valadoc_version).tar.xz
        cd valadoc-$(valadoc_version)
        export PKG_CONFIG_PATH=$(dirname $PWD)/build/lib/pkgconfig
        export LD_LIBRARY_PATH="$(dirname $PWD)/build/lib"
        ./configure CFLAGS="-I$(dirname $PWD)/build/include -fPIC" \
            VALAC="$(dirname $PWD)/build/bin/valac --vapidir $(dirname $PWD)/build/share/vala/vapi" \
            --prefix=$(dirname $PWD)/build
        make -j8
        make install
        cd ..
        rm -rf valadoc-$(valadoc_version)
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
        ./configure --prefix=$(dirname $PWD)/build
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
        export PKG_CONFIG_PATH=$(dirname $PWD)/build/lib/pkgconfig
        ./configure \
            CFLAGS="-fPIC" \
            --prefix=$(dirname $PWD)/build --disable-shared --enable-static --enable-xinput --without-doxygen
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
    rm -rf vala-$(vala_version)
    rm -rf vala
    rm -f libgee-build.stamp
    rm -rf libgee-$(libgee_version)
    rm -rf libgee
    rm -f valadoc-build.stamp
    rm -rf valadoc-$(valadoc_version)
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
    rm -rf checkout
    rm -f vala-*.tar.xz
    rm -f libgee-*.tar.xz
    rm -f valadoc-*.tar.xz
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

cd $(dirname $0)/bootstrap

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
