#!/bin/sh
set -e

if [ "$1" != "dbus-run-session" ]; then
  sudo dbus-uuidgen --ensure
  export "$(dbus-launch)"
fi

exec "$@"