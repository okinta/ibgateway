#!/usr/bin/env bash

#
# Forwards the IB Gateway port to port 7000
#

PORT=4001
if [ "$MODE" = paper ]; then
    PORT=4002
fi

echo "Waiting for API to start"
wait-for-it 127.0.0.1:$PORT
echo "API is ready"
socat TCP-LISTEN:7000,fork TCP:127.0.0.1:$PORT
