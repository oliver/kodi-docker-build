#!/usr/bin/env sh

set -e

cmake ./../source \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DCORE_PLATFORM_NAME=x11 \
      -DENABLE_INTERNAL_DAV1D=ON \
      -DAPP_RENDER_SYSTEM=gl \
      -DENABLE_INTERNAL_FFMPEG=ON

cmake --build . -- VERBOSE=1 -j2
