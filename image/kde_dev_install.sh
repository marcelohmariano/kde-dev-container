#!/usr/bin/env bash
set -e

if [ -n "$1" ]; then
  case $1 in
    plasma-desktop)
      zypper -n install -t pattern kde_plasma
      zypper -n install --no-recommends dolphin
      ;&
    kde-frameworks)
      zypper -n install --recommends -t pattern devel_kde_frameworks
      ;;
    qt)
      zypper -n install --recommends -t pattern devel_qt5
      ;;
  esac
fi