#!/bin/bash

cd $(dirname $0)

if [ -d vertex-theme ]
then
    (
    cd vertex-theme
    git pull
    )
else
    git clone https://github.com/horst3180/vertex-theme
fi

if [ -d /usr/share/themes/Vertex ] || \
    [ -d /usr/share/themes/Vertex-Dark ] || \
    [ -d /usr/share/themes/Vertex-Light ]
then
    echo Please remove old package first
    exit 1
fi


cd vertex-theme

cat << EOF > description-pak
Vertex is a theme for GTK 3, GTK 2, Gnome-Shell and Cinnamon. It supports GTK 3 and GTK 2 based desktop environments like Gnome, Cinnamon, Mate, XFCE, Budgie, Pantheon, etc.
EOF

./autogen.sh --prefix=/usr
make
fakeroot checkinstall \
    --pkgname=vertex-theme \
    --pkgversion=$(date +%Y.%m.%d) \
    --pkgarch=all \
    --pkgsource="https://github.com/horst3180/vertex-theme" \
    --provides=vertext-theme \
    --maintainer="Ildar Akhmetgaleev \<akhilman@gmail.com\>" \
    --nodoc  \
    --default \
    make install

