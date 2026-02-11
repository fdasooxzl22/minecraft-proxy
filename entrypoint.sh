#!/bin/sh
set -e

# Detect external IP address (BusyBox-compatible)
# Try to get primary interface IP using route
EXTERNAL_IP=$(ip -4 route get 1.1.1.1 2>/dev/null | grep -o 'src [0-9.]*' | awk '{print $2}' | head -1)

# Fallback to eth0 if route method fails
if [ -z "$EXTERNAL_IP" ]; then
  EXTERNAL_IP=$(ip -4 addr show eth0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1 | head -1)
fi

# Fallback to hostname -i if other methods fail
if [ -z "$EXTERNAL_IP" ]; then
  EXTERNAL_IP=$(hostname -i | awk '{print $1}')
fi

# Validate that we have an IP address
if [ -z "$EXTERNAL_IP" ]; then
  echo "Error: Could not detect external IP address" >&2
  exit 1
fi

# Validate IP address format and octet ranges
if ! echo "$EXTERNAL_IP" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'; then
  echo "Error: Invalid IP address format: $EXTERNAL_IP" >&2
  exit 1
fi

# Validate each octet is between 0-255
for octet in $(echo "$EXTERNAL_IP" | tr '.' ' '); do
  if [ "$octet" -gt 255 ] 2>/dev/null || [ "$octet" -lt 0 ] 2>/dev/null; then
    echo "Error: Invalid IP address octet: $EXTERNAL_IP" >&2
    exit 1
  fi
done

echo "Using external IP: $EXTERNAL_IP"

# Generate sockd.conf from template
sed "s/EXTERNAL_IP/$EXTERNAL_IP/g" /etc/sockd.conf.template > /etc/sockd.conf

# Start Dante SOCKS5 proxy
exec sockd -f /etc/sockd.conf -N
