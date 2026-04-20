#!/bin/bash
# this script is intended to be run in MSYS2 CLANG64

VERSION="5.15.2"

BOLD="\x1b[1m"
GREEN="\x1b[32m"
RESET="\x1b[0m"

# system update (skip this most of the time)
echo -e "${BOLD}Updating system...${RESET}"
pacman -Syu

# install deps
echo -e "${BOLD}Installing dependencies...${RESET}"
pacman -S zip git mingw-w64-clang-x86_64-{clang,cmake,ninja,curl-winssl,libpng,libjpeg-turbo,freetype,libogg,libvorbis,sqlite3,openal,zstd,gettext,luajit,SDL2}

# download and extract sources - TODO: download, compile, and use luajit
echo -e "${BOLD}Downloading Luanti source code...${RESET}"
curl -Lo luanti.tar.gz https://github.com/luanti-org/luanti/archive/refs/tags/${VERSION}.tar.gz

gunzip luanti.tar.gz
tar -xf luanti.tar

cd luanti-${VERSION}/

# configure
echo -e "${BOLD}Preparing to compile...${RESET}"
cmake . -G Ninja -DRUN_IN_PLACE=TRUE -DBUILD_CLIENT=FALSE -DBUILD_SERVER=TRUE

# compile
echo -e "${BOLD}Compiling Luanti...${RESET}"
ninja -j$(nproc)

# bundle DLLs
echo -e "${BOLD}Bundling DLLs...${RESET}"
chmod +x ../bundle_dlls.sh
../bundle_dlls.sh bin/luantiserver.exe bin/

# build the zip archive of luantiserver
echo -e "${BOLD}Building zip file...${RESET}"
mkdir -p luantiserver-${VERSION}-msys2-win64/{textures,games}

cp -r bin/ builtin/ doc/ mods/ worlds/ luantiserver-${VERSION}-msys2-win64/
cp textures/texture_packs_here.txt luantiserver-${VERSION}-msys2-win64/textures/

zip -r9 luantiserver-${VERSION}-msys2-win64.zip luantiserver-${VERSION}-msys2-win64/

# clean up
echo -e "${BOLD}Cleaning up...${RESET}"
mv luantiserver-${VERSION}-msys2-win64.zip ..
cd ..
rm -rf luanti{.tar,-${VERSION}}

echo -e "${BOLD}${GREEN}Done!${RESET}"
