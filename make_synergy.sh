#!/bin/bash

# instal dependences
# sudo apt-get install build-essential cmake libavahi-compat-libdnssd-dev libcurl4-openssl-dev libssl-dev lintian python qt4-dev-tools xorg-dev

if [ -d synergy ]
then
    ( cd synergy; git pull)
else
    git clone https://github.com/symless/synergy synergy
fi

(
    cd synergy
    python hm.py setup -g 1
    python hm.py conf
    python hm.py build
    python hm.py package deb
)
