#!/bin/sh
set -e

echo "Starting Dante SOCKS5 proxy..."

# Get container IP address
EXTERNAL_IP=$(ip -4 addr show eth0 2>/dev/null | grep -o 'inet [0-9.]*' | head -1 | awk '{print $2}')

# Fallback to hostname -i if eth0 doesn't exist
if [ -z "$EXTERNAL_IP" ]; then
    EXTERNAL_IP=$(hostname -i | awk '{print $1}')
fi

# Check if IP detection failed
if [ -z "$EXTERNAL_IP" ]; then
    echo "ERROR: Failed to detect external IP address"
    exit 1
fi

echo "Detected external IP: $EXTERNAL_IP"

# Replace placeholder with actual IP
sed "s/EXTERNAL_IP/$EXTERNAL_IP/g" /etc/sockd.conf.template > /etc/sockd.conf

echo "Configuration file generated:"
cat /etc/sockd.conf

# Start Dante in foreground
echo "Starting sockd..."
exec sockd -f /etc/sockd.conf -N
