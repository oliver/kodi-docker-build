# Docker Image for building [Kodi](https://github.com/xbmc/xbmc)

This a is Docker image for building Kodi based on Ubuntu. It is useful if you are working on
Kodi and don't want to litter your OS with Kodi build dependencies.

By default this builds Kodi, the official add-ons, and many game add-ons from
the [kodi-game](https://github.com/kodi-game/repo-binary-addons) repository.

## Requirements

* [Docker](https://docs.docker.com/engine/install/) >= 19.03

## Building Kodi

### Prepare Docker image

```sh
docker build -t kodi-docker-build .
```

> You can do a fresh build by adding the `--no-cache` flag.

### Link source code

Create a symlink to your Kodi source:

```sh
ln -s <path_to_kodi_source> xbmc
```

> Or if you just want to build the current `master`-branch, simply execute
  `git clone https://github.com/xbmc/xbmc.git`.

### Create Build Output Directory

```sh
mkdir -p ~/tmp/kodibuild
```

### Build Kodi inside Docker

> The build will take up a lot of memory, so make sure to limit it accordingly.   
> If you run into memory issues, adapt `build.sh` to only use one job (`-j1`).

```sh
docker run \
  --rm \
  -it \
  --memory "8g" \
  --memory-swap "8g" \
  --volume $(readlink -f xbmc):/kodi/source/kodi \
  --volume ~/tmp/kodibuild:/kodi/build \
  kodi-docker-build:latest build.sh
```

The first build will take a few hours.
It will create ca. 15 GB of temporary data and 1.5 GB of final results (in `kodi_install/`).

## Testing the build

You should find a `kodi` file in the `tmp/kodibuild/build/kodi_install/bin` folder in your home directory.

Execute it to test your build. If it does not work because
of missing libraries, there are two options:

1) Install Kodi via `apt`:

```sh
sudo add-apt-repository ppa:team-xbmc/xbmc-nightly
sudo apt-get update
sudo apt-get install kodi
```

This will install all missing dependencies.

2) Run Kodi in a Docker container, using [x11docker](https://github.com/mviereck/x11docker):

```sh
git clone https://github.com/mviereck/x11docker.git
cd x11docker
./x11docker --desktop --size 1280x800 -i --gpu --network=host --sudouser --pulseaudio -- --rm --volume ~/tmp/kodibuild/kodi_install:/kodi/build/kodi_install -- kodi-docker-build:latest bash
/kodi/build/kodi_install/bin/kodi --windowing=x11
```

### Add-ons

The add-ons are automatically installed into `kodi_install/` directory.
They can be enabled in Kodi under Add-ons -> My add-ons.

## Clean up

Run `sudo git clean -xdf` to clean the `build` folder.

## Copyright and license

Licensed under the MIT License - see `LICENSE` for details.
