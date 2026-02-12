#!/bin/sh
set -e

EXTERNAL_IP=$(ip -4 addr show eth0 2>/dev/null | grep -o 'inet [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | cut -d' ' -f2 | head -1)
if [ -z "$EXTERNAL_IP" ]; then
  EXTERNAL_IP=$(hostname -i | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
fi

sed "s/EXTERNAL_IP/$EXTERNAL_IP/g" /etc/sockd.conf.template > /etc/sockd.conf
exec sockd -f /etc/sockd.conf -N
