#!/bin/bash

CC=gcc
CXX=g++
CFLAGS="-O2 -pipe -march=native" 
CXXFLAGS=$CFLAGS

MAKE_OPTS="-j$(( $(cat /proc/cpuinfo | grep processor | wc -l) +1 ))"
CONF_OPTS=

PY3VERS=$(py3versions -dv)

conf_default()
{
    cd $SRCDIR || return $? 
    [ -x ./autogen.sh ] && ./autogen.sh
    CC=$CC CXX=$CXX CFLAGS=$CFLAGS CXXFLAGS=$CXXFLAGS ./configure --prefix=$PREFIX $CONF_OPTS || return $?
}

conf ()
{
    conf_default
}

mk_default()
{
    [ -d $SRCDIR ] || return 1
    cd $SRCDIR || return $? 

    make $MAKE_OPTS $@ || return $?

    [ x$1 = xinstall ] && mark_uptodate
    return 0
}

mk()
{
    mk_default $@
}

get()
{
    echo get
}

showinfo()
{
    cd $SRCDIR || return $? 
    date
    pwd
    echo getinifo
}

get_svn()
{
    [ -e $(dirname $SRCDIR) ] || mkdir -p $(dirname $SRCDIR) 
    cd $(dirname $SRCDIR) 

    if [ -e $SRCDIR ]
    then
	( cd $SRCDIR && svn update ) || return $?
    else
	cd $(dirname $SRCDIR)
	svn co $@ $(basename $SRCDIR) || return $?
    fi
}

showinfo_svn()
{
    cd $SRCDIR || return $? 
    date
    pwd
    svn info
}

get_git()
{
    [ -e $(dirname $SRCDIR) ] || mkdir -p $(dirname $SRCDIR) 
    cd $(dirname $SRCDIR) 

    if [ -e $SRCDIR ]
    then
	( cd $SRCDIR \
	    && git pull -f \
	    ) || return $?
    else
	cd $(dirname $SRCDIR)
	git clone $@ $(basename $SRCDIR) || return $?
    fi
}

showinfo_git()
{
    cd $SRCDIR || return $? 
    date
    pwd
    git --no-pager log -n 1 
}

get_mercurial()
{
    [ -e $(dirname $SRCDIR) ] || mkdir -p $(dirname $SRCDIR) 
    cd $(dirname $SRCDIR) 

    if [ -e $SRCDIR ]
    then
	( cd $SRCDIR && hg pull && hg update ) || return $?
    else
	cd $(dirname $SRCDIR)
	hg clone $@ $(basename $SRCDIR) || return $?
    fi
}

showinfo_mercurial()
{
    cd $SRCDIR || return $? 
    date
    pwd
    #git-check-attr
}

is_uptodate()
{
    cd $SRCDIR || return $? 
    [ -r $BUILDDIR/lastbuilt ] || return 1
    [ $(find $SOURCEDIR -newer $BUILDDIR/lastbuilt | grep -v --extended-regexp '\/(\.svn|CVS|.git)' | wc -l) -gt 0 ] && return 1
    return 0
}

mark_uptodate()
{
    showinfo | tee $BUILDDIR/lastbuilt
}

main ()
{
    [ -d $BUILDDIR ] || mkdir -p  $BUILDDIR
    echo "    ---=== $NAME ===---"
    echo ${0##*/} $@
    echo
    case $1 in
	info)
	    showinfo
	    exit $?;;
	get)
	    get || exit $?
	    exit $?;;
	configure)
	    conf || exit $?
	    exit $?;;
	update)
	    get
	    if is_uptodate
	    then
		echo "nothing to do"
		exit 0
	    fi
	    mk && mk install || exit $?
	    exit $?;;
	rebuild)
	    mk clean 
	    conf && mk && mk install || exit $?
	    exit $?;;
	initialize)
	    mk clean 
	    get && conf && mk && mk install || exit $?
	    exit $?;;
	*)
	    mk $@ || exit $?
	    exit $?;;
    esac
}



