#!/usr/bin/env sh

set -e

cmake ./../source \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DCMAKE_GENERATOR=Ninja \
      -DCORE_PLATFORM_NAME="x11 gbm wayland" \
      -DENABLE_INTERNAL_DAV1D=ON \
      -DAPP_RENDER_SYSTEM=gl \
      -DENABLE_INTERNAL_FFMPEG=ON

cmake --build . -- -j2
