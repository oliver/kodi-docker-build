FROM ubuntu:24.04

# Create working directory
WORKDIR /kodi/build

# Kodi source code has to be mounted in this folder
VOLUME /kodi/source

# Kodi will be built in this folder
VOLUME /kodi/build

# Install build dependencies
# (the package list in long "install" command must be identical to the command from https://github.com/xbmc/xbmc/blob/master/docs/README.Ubuntu.md#32-get-build-dependencies-manually)
RUN apt-get update && \
    apt-get install --assume-yes ccache software-properties-common nano less aptitude sudo && \
    apt-get install --assume-yes autoconf automake autopoint autotools-dev cmake \
      curl debhelper default-jre doxygen gawk gcc gdc gettext gperf \
      libasound2-dev libass-dev libavahi-client-dev libavahi-common-dev \
      libbluetooth-dev libbluray-dev libbz2-dev libcdio-dev \
      libcrossguid-dev libcurl4-openssl-dev libcwiid-dev libdbus-1-dev \
      libdrm-dev libegl1-mesa-dev libenca-dev libexiv2-dev libflac-dev \
      libfmt-dev libfontconfig-dev libfreetype6-dev libfribidi-dev \
      libfstrcmp-dev libgcrypt-dev libgif-dev libgl1-mesa-dev \
      libgles2-mesa-dev libglu1-mesa-dev libgnutls28-dev libgpg-error-dev \
      libgtest-dev libiso9660-dev libjpeg-dev liblcms2-dev libltdl-dev \
      liblzo2-dev libmicrohttpd-dev libmysqlclient-dev libnfs-dev \
      libogg-dev libp8-platform-dev libpcre2-dev libplist-dev libpng-dev \
      libpulse-dev libshairplay-dev libsmbclient-dev libspdlog-dev \
      libsqlite3-dev libssl-dev libtag1-dev libtiff5-dev libtinyxml-dev \
      libtinyxml2-dev libtool libudev-dev libunistring-dev libva-dev \
      libvdpau-dev libvorbis-dev libxmu-dev libxrandr-dev libxslt1-dev \
      libxt-dev lsb-release meson nasm ninja-build nlohmann-json3-dev \
      python3-dev python3-pil python3-pip swig unzip uuid-dev zip \
      zlib1g-dev

# Install additional dependencies (as described at https://github.com/xbmc/xbmc/blob/master/docs/README.Ubuntu.md#32-get-build-dependencies-manually):
# - for Ubuntu >= 20.04
# - for extra functionality
RUN apt-get update && \
    apt-get install --assume-yes libflatbuffers-dev && \
    apt-get install --assume-yes doxygen libcap-dev libsndio-dev libmariadbd-dev

# Add full password-less sudo permissions for build user, for easier development
RUN echo 'build   ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/build-user

# Add build script
COPY build.sh /usr/local/bin

# Create user
# TODO: is this separate user still necessary, if ubuntu:24.04 has the "ubuntu" user built-in?
RUN groupadd --gid 1005 build && \
    useradd --uid 1005 --gid build --shell /bin/bash --create-home build;

# Use `build`-user to create files with matching permissions
USER build
