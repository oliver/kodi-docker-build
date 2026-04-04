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
It will create ca. 19 GB of temporary data and 2.5 GB of final results (in `kodi_install/`).

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

## Using Custom Add-on Code

By default the `build.sh` script will download and build the latest official add-ons from the repository specified in the Kodi source code under `cmake/addons/bootstrap/repositories/binary-addons.txt` .
And in addition the `build.sh` script will also download and build some add-ons from the kodi-game repository (https://github.com/kodi-game/repo-binary-addons.git).

You can also build an add-on with your own modifications.
E.g. to build your own code of the pvr.demo add-on, follow these steps:

- check out the add-on repository itself (https://github.com/kodi-pvr/pvr.demo), e.g. to `pvr.demo/` in your home directory.
- mount that checkout into the Docker container (e.g. with `--volume ~/pvr.demo/:/kodi/source/pvr.demo/` .
- check out https://github.com/xbmc/repo-binary-addons , e.g. to `repo-binary-addons/` in your home directory.
- mount that checkout into the Docker container as well (e.g. with `--volume ~/repo-binary-addons/:/kodi/source/repo-binary-addons/` .
- in your local checkout of repo-binary-addons, edit the `pvr.demo/pvr.demo.txt` file and specify the path where your pvr.demo code will be located in the Docker container; e.g. like this:
  `pvr.demo file:///kodi/source/pvr.demo`
- commit the changes in your repo-binary-addons checkout (this is important because the build system will perform a Git clone from your local checkout).
  - remember the branch on which you committed the changes; it must be specified as `-DREPOSITORY_REVISION` below. I'll assume the branch is called `my_changes`.
- after building Kodi as usual (using the build.sh script), build your own code of the pvr.demo add-on, like this:
```
cd /kodi/build
mkdir -p addons_mine_bootstrap_cmake
cd addons_mine_bootstrap_cmake
cmake /kodi/source/kodi/cmake/addons/bootstrap/ \
      -DCMAKE_GENERATOR=Ninja \
      -DREPOSITORY_TO_BUILD=/kodi/source/repo-binary-addons/ \
      -DREPOSITORY_REVISION=my_changes \
      -DCMAKE_INSTALL_PREFIX=/kodi/build/addons_kodigame_bootstrap_install \
      -DBUILD_DIR=/kodi/build/addons_kodigame_bootstrap_build
cmake --build .

cd /kodi/build
mkdir -p addons_mine_build_cmake
cd addons_mine_build_cmake
cmake /kodi/source/kodi/cmake/addons/ \
      -DCMAKE_GENERATOR=Ninja \
      -DADDONS_TO_BUILD="pvr.demo" \
      -DADDONS_DEFINITION_DIR=/kodi/build/addons_mine_bootstrap_install \
      -DCMAKE_INSTALL_PREFIX=/kodi/build/kodi_install/share/kodi/addons/ \
      -DBUILD_DIR=/kodi/build/addons_mine_build_build \
      -DPACKAGE_ZIP=1
cmake --build . -- -j1
```

This will build only the pvr.demo add-on (as specified with `-DADDONS_TO_BUILD`).
It will use the add-on repository from `/kodi/source/repo-binary-addons/` (as specified with `-DREPOSITORY_TO_BUILD`) at the branch `my_changes` (as specified with `-DREPOSITORY_REVISION`).
The built add-on will be installed into the normal Kodi installation directory (`/kodi/build/kodi_install/share/kodi/addons/`), as specified with `-DCMAKE_INSTALL_PREFIX` in the second `cmake` command.

From now on, the add-on can be rebuilt and re-installed by running `cmake --build . -- -j1` in the `/kodi/build/addons_mine_build_cmake/` directory again.

References:
- Building Kodi add-ons: https://github.com/xbmc/xbmc/blob/master/cmake/addons/README.md
- "Bootstrapping" system for building Kodi add-ons: https://github.com/xbmc/xbmc/blob/master/cmake/addons/bootstrap/README.md
- Dependency system for building Kodi add-ons: https://github.com/xbmc/xbmc/blob/master/cmake/addons/depends/README

## Copyright and license

Licensed under the MIT License - see `LICENSE` for details.
