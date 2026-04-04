#!/usr/bin/env sh

# exit on errors:
set -e

# show commands:
set -x

# run at low priority
ionice -n 7 -p $$
renice 3 -p $$ > /dev/null


# Build Kodi itself
cd /kodi/build
mkdir -p kodi_build
cd kodi_build
cmake /kodi/source/kodi \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/kodi/build/kodi_install \
      -DCMAKE_GENERATOR=Ninja \
      -DCORE_PLATFORM_NAME="x11 gbm wayland" \
      -DADDONS_CONFIGURE_AT_STARTUP=0 \
      -DENABLE_INTERNAL_DAV1D=ON \
      -DAPP_RENDER_SYSTEM=gl \
      -DENABLE_INTERNAL_FFMPEG=ON

# First build just crossguid (with -DCMAKE_BUILD_TYPE=Release), then reconfigure the build directory and build Kodi itself (and the remaining dependencies) with -DCMAKE_BUILD_TYPE=RelWithDebInfo:
cmake --build . -- build-crossguid
cmake /kodi/source/kodi \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo

cmake --build .
cmake --build . -- install


# Build official Kodi addons
cd /kodi/build

# Download source repository for official addons
# (this currently uses a custom repo-binary-addons repository with fixes necessary for building under Debian Forky)
mkdir -p addons_official_bootstrap_cmake
cd addons_official_bootstrap_cmake
cmake /kodi/source/kodi/cmake/addons/bootstrap/ \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_GENERATOR=Ninja \
      -DREPOSITORY_TO_BUILD=https://github.com/oliver/repo-binary-addons.git \
      -DREPOSITORY_REVISION=debian_forky \
      -DCMAKE_INSTALL_PREFIX=/kodi/build/addons_official_bootstrap_install \
      -DBUILD_DIR=/kodi/build/addons_official_bootstrap_build
cmake --build .

# Build all official addons
cd /kodi/build
mkdir -p addons_official_build_cmake
cd addons_official_build_cmake
cmake /kodi/source/kodi/cmake/addons/ \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_GENERATOR=Ninja \
      -DADDONS_TO_BUILD="" \
      -DADDONS_DEFINITION_DIR=/kodi/build/addons_official_bootstrap_install \
      -DCMAKE_INSTALL_PREFIX=/kodi/build/kodi_install/share/kodi/addons/ \
      -DBUILD_DIR=/kodi/build/addons_official_build_build \
      -DPACKAGE_ZIP=1
cmake --build . -- -j1


# Build some addons from "kodi-game" repository
cd /kodi/build

# Download source repository for kodi-game addons
mkdir -p addons_kodigame_bootstrap_cmake
cd addons_kodigame_bootstrap_cmake
cmake /kodi/source/kodi/cmake/addons/bootstrap/ \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_GENERATOR=Ninja \
      -DREPOSITORY_TO_BUILD=https://github.com/kodi-game/repo-binary-addons.git \
      -DREPOSITORY_REVISION=retroplayer-piers \
      -DCMAKE_INSTALL_PREFIX=/kodi/build/addons_kodigame_bootstrap_install \
      -DBUILD_DIR=/kodi/build/addons_kodigame_bootstrap_build
cmake --build .

# Build some kodi-game addons
cd /kodi/build
mkdir -p addons_kodigame_build_cmake
cd addons_kodigame_build_cmake
kodigame_addons_to_build=\
'game..* '\
'-game.libretro$ '\
'-game.libretro.beetle-bsnes$ '\
'-game.libretro.daphne$ '\
'-game.libretro.dolphin$ '\
'-game.libretro.dosbox-core$ '\
'-game.libretro.flycast$ '\
'-game.libretro.fsuae$ '\
'-game.libretro.lrps2$ '\
'-game.libretro.*mame.*$ '\
'-game.libretro.parallel_n64$ '\
'-game.libretro.parallext$ '\
'-game.libretro.pcem$ '\
'-game.libretro.ppsspp$ '\
'-game.libretro.quasi88$ '\
'-game.libretro.redbook$ '\
'-game.libretro.same_cdi$ '\
'-game.libretro.scummvm$ '\
'-game.libretro.uae4arm$ '\
'-game.libretro.*vice.*$ '\

cmake /kodi/source/kodi/cmake/addons/ \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_GENERATOR=Ninja \
      -DADDONS_TO_BUILD="$kodigame_addons_to_build" \
      -DADDONS_DEFINITION_DIR=/kodi/build/addons_kodigame_bootstrap_install \
      -DCMAKE_INSTALL_PREFIX=/kodi/build/kodi_install/share/kodi/addons/ \
      -DBUILD_DIR=/kodi/build/addons_kodigame_build_build \
      -DPACKAGE_ZIP=1
cmake --build . -- -j1
