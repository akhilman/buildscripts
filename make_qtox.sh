#!/bin/bash

WD=$(cd $(dirname $0) && pwd)
BUILDDIR=$WD/qtox
BUILDSCRIPT=$WD/$(basename $0)
INSTALLDIR=$HOME/.local/opt/qTox


mkdir -p $BUILDDIR
mkdir -p $INSTALLDIR
cd $BUILDDIR


if which firejail; then
    if [ _$1 == _jail ]; then
        shift
    else
        firejail \
            --noprofile \
            --whitelist=$BUILDSCRIPT \
            --whitelist=$BUILDDIR \
            --whitelist=$INSTALLDIR \
            bash $BUILDSCRIPT jail $@
        exit $?
    fi
fi


fetch() {

    cd $BUILDDIR
    if [ -d toxcore ]; then
        cd toxcore && git pull || exit $1
    else
        git clone https://github.com/irungentoo/toxcore.git || exit $1
    fi

    cd $BUILDDIR
    if [ -d qTox ]; then
        cd qTox && git pull || exit $1
    else
        git clone https://github.com/qTox/qTox.git qTox || exit $1
    fi

}

build_toxcore() {

    cd $BUILDDIR/toxcore
    autoreconf -if || exit $?
    ./configure --prefix=$INSTALLDIR || exit $?
    make -j$(nproc)
    make install
}

build_qtox() {
    cd $BUILDDIR/qTox
    cat qtox.pro > qtox.tmp.pro
    echo INCLUDEPATH += $INSTALLDIR/include >> qtox.tmp.pro
    echo LIBS += -L$INSTALLDIR/lib >> qtox.tmp.pro
    qmake PREFIX=$INSTALLDIR qtox.tmp.pro
    make -j$(nproc) install
}


if [ _$1 == _fetch ]; then
    fetch || exit $?
elif [ _$1 == _build ]; then
    build_toxcore || exit $?
    build_qtox || exit $?
else
    fetch || exit $?
    build_toxcore || exit $?
    build_qtox || exit $?
fi
