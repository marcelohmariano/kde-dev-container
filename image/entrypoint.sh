#!/bin/sh
set -e

if [ "$1" != "dbus-run-session" ]; then
  sudo dbus-uuidgen --ensure
  export $(dbus-launch)
fi

if [ -n "$TZ" ]; then
  sudo rm -f /etc/localtime
  sudo ln -s "/usr/share/zoneinfo/${TZ}" /etc/localtime
  unset TZ
fi

exec "$@"