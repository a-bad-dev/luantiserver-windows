#!/bin/bash
#
# this script is intended to be run in MSYS2 CLANG64
#

VERSION="5.15.2"

# system update (skip this most of the time)
pacman -Syu

# install deps
pacman -S zip git mingw-w64-clang-x86_64-{clang,cmake,ninja,curl-winssl,libpng,libjpeg-turbo,freetype,libogg,libvorbis,sqlite3,openal,zstd,gettext,luajit,SDL2}

# download and extract sources
curl -Lo luanti.tar.gz https://github.com/luanti-org/luanti/archive/refs/tags/${VERSION}.tar.gz

gunzip luanti.tar.gz
tar -xf luanti.tar

cd luanti-${VERSION}/

# configure
cmake . -G Ninja -DRUN_IN_PLACE=TRUE -DBUILD_CLIENT=FALSE -DBUILD_SERVER=TRUE

# compile
ninja -j$(nproc)

# bundle DLLs
chmod +x ../bundle_dlls.sh

../bundle_dlls.sh bin/luantiserver.exe bin/

# build the zip archive of luantiserver
mkdir -p luantiserver-${VERSION}-msys2-win64/textures/

cp -r bin/ builtin/ games/ mods/ worlds/ luantiserver-${VERSION}-msys2-win64/
cp textures/texture_packs_here.txt luantiserver-${VERSION}-msys2-win64/textures/

zip -r9 luantiserver-${VERSION}-msys2-win64.zip luantiserver-${VERSION}-msys2-win64/

# clean up
mv luantiserver-${VERSION}-msys2-win64.zip ..
cd ..
rm -rf luanti{.tar,-${VERSION}}

echo "done"
