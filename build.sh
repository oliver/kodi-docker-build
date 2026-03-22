#!/usr/bin/env sh

set -e

# Build Kodi itself
cd /kodi/build
mkdir kodi_build
cd kodi_build
cmake /kodi/source \
      -DCMAKE_INSTALL_PREFIX=/kodi/build/kodi_install \
      -DCMAKE_GENERATOR=Ninja \
      -DCORE_PLATFORM_NAME="x11 gbm wayland" \
      -DADDONS_CONFIGURE_AT_STARTUP=0 \
      -DENABLE_INTERNAL_DAV1D=ON \
      -DAPP_RENDER_SYSTEM=gl \
      -DENABLE_INTERNAL_FFMPEG=ON

cmake --build . -- -j2
cmake --build . -- install


# Build addons
cd /kodi/build

# Download source repository for official addons
# (this uses the repository described in /kodi/source/cmake/addons/bootstrap/repositories/binary-addons.txt)
mkdir addons_bootstrap_cmake
cd addons_bootstrap_cmake
cmake /kodi/source/cmake/addons/bootstrap/ \
      -DCMAKE_INSTALL_PREFIX=/kodi/build/addons_bootstrap_install \
      -DBUILD_DIR=/kodi/build/addons_bootstrap_build
cmake --build .

# Build all official addons
cd /kodi/build
mkdir addons_build_cmake
cd addons_build_cmake
cmake /kodi/source/cmake/addons/ \
      -DADDONS_TO_BUILD="" \
      -DADDONS_DEFINITION_DIR=/kodi/build/addons_bootstrap_install \
      -DCMAKE_INSTALL_PREFIX=/kodi/build/kodi_install/share/kodi/addons/ \
      -DBUILD_DIR=/kodi/build/addons_build_build \
      -DPACKAGE_ZIP=1
cmake --build . -- -j2
