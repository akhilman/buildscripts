#!/bin/bash

WRKDIR=`dirname $0`
WRKDIR=`( cd $WRKDIR && pwd )`

source $WRKDIR/make_common.sh

[ x$NAME = x ]	   && NAME=vim
[ x$SRCDIR = x ]   && SRCDIR=$WRKDIR/$NAME
[ x$BUILDDIR = x ] && BUILDDIR=$WRKDIR/.build/$NAME
[ x$PREFIX = x ]   && PREFIX=$HOME/.local/opt/$NAME

CC=gcc
CXX=g++
CFLAGS=$CFLAGS
CXXFLAGS=$CFLAGS

export LD_LYBRATY_PATH=$(python3-config --prefix)/lib

conf()
{
	 cd $SRCDIR || return 1
	./configure \
		--prefix=$PREFIX \
		--enable-python3interp \
        vi_cv_path_python3=$(which python3) \
        --with-python3-config-dir=$(python3-config --configdir) \
		--enable-cscope \
        --enable-gui=gtk2 \
		--with-features=huge \
		--enable-multibyte 

}

get()
{
    get_git "https://github.com/vim/vim.git"

}

mk()
{
    if [ "_$@" = _clean ]
    then
        mk_default distclean
    elif [ _$1 = _install ]
    then
        rm -v $PREFIX/bin/*
        mk_default $@
    else
        mk_default $@
    fi
}

showinfo()
{
    showinfo_git $@
}

main $@

