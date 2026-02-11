#!/bin/sh
set -e

echo "Starting Dante SOCKS5 proxy..."

# Get container IP address
EXTERNAL_IP=$(ip -4 addr show eth0 2>/dev/null | grep -o 'inet [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -1 | awk '{print $2}')

# Fallback to hostname -i if eth0 doesn't exist
if [ -z "$EXTERNAL_IP" ]; then
    EXTERNAL_IP=$(hostname -i | awk '{print $1}')
fi

# Check if IP detection failed
if [ -z "$EXTERNAL_IP" ]; then
    echo "ERROR: Failed to detect external IP address"
    exit 1
fi

# Validate IP format (basic validation)
if ! echo "$EXTERNAL_IP" | grep -Eq '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'; then
    echo "ERROR: Invalid IP address format: $EXTERNAL_IP"
    exit 1
fi

echo "Detected external IP: $EXTERNAL_IP"

# Replace placeholder with actual IP (escape forward slashes for sed)
ESCAPED_IP=$(echo "$EXTERNAL_IP" | sed 's/\//\\\//g')
sed "s/EXTERNAL_IP/$ESCAPED_IP/g" /etc/sockd.conf.template > /etc/sockd.conf

if [ -n "$DEBUG" ]; then
    echo "Configuration file generated:"
    cat /etc/sockd.conf
fi

# Start Dante in foreground
echo "Starting sockd..."
exec sockd -f /etc/sockd.conf -N
