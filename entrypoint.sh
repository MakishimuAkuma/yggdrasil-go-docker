#!/bin/sh

set -e

echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

CONF_DIR="/etc/yggdrasil-network"

if [ ! -f "$CONF_DIR/config.conf" ]; then
  echo "generate $CONF_DIR/config.conf"
  ./yggdrasil --genconf > "$CONF_DIR/config.conf"
fi

./yggdrasil --useconf < "$CONF_DIR/config.conf"

exit $?
