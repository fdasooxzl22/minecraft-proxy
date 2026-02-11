#!/bin/sh
set -e

# Detect external IP address (BusyBox-compatible)
EXTERNAL_IP=$(ip -4 addr show eth0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1 | head -1)

# Fallback to hostname -i if eth0 detection fails
if [ -z "$EXTERNAL_IP" ]; then
  EXTERNAL_IP=$(hostname -i | awk '{print $1}')
fi

# Validate that we have an IP address
if [ -z "$EXTERNAL_IP" ]; then
  echo "Error: Could not detect external IP address" >&2
  exit 1
fi

# Check if IP address is in valid format (basic validation)
if ! echo "$EXTERNAL_IP" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'; then
  echo "Error: Invalid IP address format: $EXTERNAL_IP" >&2
  exit 1
fi

echo "Using external IP: $EXTERNAL_IP"

# Generate sockd.conf from template
sed "s/EXTERNAL_IP/$EXTERNAL_IP/g" /etc/sockd.conf.template > /etc/sockd.conf

# Start Dante SOCKS5 proxy
exec sockd -f /etc/sockd.conf -N
