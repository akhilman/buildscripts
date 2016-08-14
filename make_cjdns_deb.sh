#!/bin/bash

to_install=
for p in git build-essential dh-systemd nodejs
do
    dpkg-query -l $p || to_install="$to_install $p" 
done
if [ ! -z "$to_install" ]
then
    sudo apt-get install $to_install
fi

cd $(dirname $0)
mkdir -p cjdns; cd cjdns

if [ -x cjdns ]
then
    (cd cjdns; git pull)
else
    git clone https://github.com/cjdelisle/cjdns.git cjdns
fi

(cd cjdns; ./clean; dpkg-buildpackage -tc -rfakeroot -uc -b)

sudo dpkg -i $(ls cjdns_*_*.deb | tail -n 1)
