# KDE Development Environment

[![GitHub](https://img.shields.io/github/license/marcelohmariano/kde-dev.svg)](LICENSE)
[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/marcelohmariano/kde-dev.svg)](https://hub.docker.com/r/marcelohmariano/kde-dev)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/marcelohmariano/kde-dev.svg)](https://hub.docker.com/r/marcelohmariano/kde-dev/builds)

A Docker container for developing KDE applications.

## Getting Started

These instructions will cover usage information and for the Docker container.

### Prerequisities

In order to run this container you'll need [Docker](https://docs.docker.com/get-started/) installed.

### Installation

Pull the image from the Docker repository:

```sh
docker pull marcelohmariano/kde-dev
docker tag marcelohmariano/kde-dev kde-dev
docker rmi marcelohmariano/kde-dev
```

Or build the image from source:

```sh
git clone https://github.com/marcelohmariano/kde-dev.git
cd kde-dev
docker build -t kde-dev .
```

### Usage

#### Run

Start Bash (this is the default when no command is specified):

```sh
docker run -it --rm kde-dev bash
```

Start a GUI application from inside the container, e.g., QtCreator:

```sh
docker run -it --rm --privileged \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix/:/tmp/.X11-unix \
  -v $HOME/.Xauthority:/home/dev/.Xauthority \
  --network host \
  kde-dev \
  qtcreator
```

Build a KDE project from its source repository using `kdesrc-build`:

```sh
mkdir kdesrc && cd kdesrc
docker run -it --rm -v $PWD:/home/dev/kde kde-dev bash
kdesrc-build kcalc
```

Use a custom `kdesrc-build` configuration file:

```sh
docker run -it --rm -v /path/to/your/custom/kdesrc-buildrc:/home/dev/.kdesrc-buildrc kde-dev bash
```

#### Create a Development Environment

Create a `Dockerfile` for the project you want to develop or contribute to, e.g., [Konsole](https://konsole.kde.org/) (the KDE terminal emulator):

```sh
FROM marcelohmariano/kde-dev

RUN sudo zypper -n source-install --build-deps-only konsole && sudo zypper clean -a
```

Then, build and run the Docker image:

```sh
docker build -t konsole-dev .
docker run -it --rm -v $PWD:/home/dev/kde konsole-dev bash
```

Finally, build the project using `kdesrc-build`:

```sh
kdesrc-build konsole
```

#### Environment Variables

* `DISPLAY` - the X display server that the GUI applications will connect to

#### Volumes

* `/home/dev/kde` - `kdesrc-build` work directory
* `/home/dev/.config` - user-specific configuration files

#### Useful File Locations

* `/home/dev/.kdesrc-buildrc` - `kdesrc-build` configuration file

## Built With

* Arcanist - a command-line interface to [Phabricator](https://phabricator.kde.org/)
* CMake - a cross-platform build system generator
* QtCreator - a lightweight cross-platform IDE
* KCachegrind - a profile data visualization tool for Callgrind
* Valgrind - a tool for memory debugging, memory leak detection, and profiling
* ccache - a fast compiler cache
* g++ - the GNU C++ compiler
* gdb - the GNU debugger
* kdesrc-build - a tool to build KDE projects from its source repositories

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.