#!/bin/bash

#REVISION_ARGS='-r {2014-07-01}'
WD=$(cd $(dirname $0);pwd)

echo $(whoami) '->' $(sudo whoami)

[ -d linuxsampler ] || mkdir linuxsampler

cd $WD/linuxsampler

PKGDIR=$WD/PKG
[ -d $PKGDIR ] || mkdir -p  $PKGDIR

################ libgig ################

if [ -d libgig ]
then
    cd libgig || exit $!
    svn update $REVISION_ARGS || exit $!
else
    svn co https://svn.linuxsampler.org/svn/libgig/trunk $REVISION_ARGS libgig || exit $!
    cd libgig || exit $!
fi
dpkg-buildpackage -tc -rfakeroot -uc -b -j5 || exit $!

cd $WD/linuxsampler

echo \$ sudo dpkg -i libgig*.deb 
sudo dpkg -i libgig*.deb || exit $1

################ linuxsampler ##########

if [ -d linuxsampler ]
then
    cd linuxsampler || exit $!
    svn update $REVISION_ARGS || exit $!
else
    svn co https://svn.linuxsampler.org/svn/linuxsampler/trunk $REVISION_ARGS linuxsampler || exit $!
    cd linuxsampler || exit $!
fi
dpkg-buildpackage -tc -rfakeroot -uc -b -j5 || exit $!

cd $WD/linuxsampler

echo \$ sudo dpkg -i liblinuxsampler*.deb linuxsampler*.deb 
sudo dpkg -i liblinuxsampler*.deb linuxsampler*.deb || exit $1

################ liblscp ###############

if [ -d liblscp ]
then
    cd liblscp || exit $!
    svn update $REVISION_ARGS || exit $!
else
    svn co https://svn.linuxsampler.org/svn/liblscp/trunk $REVISION_ARGS liblscp || exit $!
    cd liblscp || exit $!
fi
dpkg-buildpackage -tc -rfakeroot -uc -b -j5 || exit $!

cd $WD/linuxsampler

echo \$ sudo dpkg -i liblscp*.deb 
sudo dpkg -i liblscp*.deb || exit $1

################ qsampler ##############

if [ -d qsampler ]
then
    cd qsampler || exit $!
    svn update $REVISION_ARGS || exit $!
else
    svn co https://svn.linuxsampler.org/svn/qsampler/trunk $REVISION_ARGS qsampler || exit $!
    cd qsampler || exit $!
fi
dpkg-buildpackage -tc -rfakeroot -uc -b -j5 || exit $!

cd $WD/linuxsampler

echo \$ sudo dpkg -i qsampler*.deb
sudo dpkg -i qsampler*.deb || exit $1

##################

ls *.deb | sed -n 's/\(.*\)_[0-9\._-]*_.*\.deb/\1/p' | xargs sudo apt-mark hold 
[ -d debs ] || mkdir debs
rm debs/*.deb debs/*.changes
mv *.deb *.changes debs/
