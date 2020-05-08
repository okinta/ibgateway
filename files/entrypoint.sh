#!/usr/bin/env bash

if [ -z "$LOGIN" ]; then
    echo "LOGIN environment variable must be set" >&2
    exit 1
fi

if [ -z "$PASSWORD" ]; then
    echo "PASSWORD environment variable must be set" >&2
    exit 1
fi

if [ -z "$MODE" ]; then
    MODE=paper
    export MODE
fi

if [[ ! "$MODE" =~ ^(live|paper)$ ]]; then
    echo "MODE environment variable must be set to either live or paper" >&2
    exit 1
fi

su ibgateway -c 'envsubst < ~/ibc/config.ini.template > ~/ibc/config.ini'

# Start Xvfb daemon so IB Gateway has somewhere to display itself
Xvfb :99 -screen 0 640x480x8 -nolisten tcp -nolisten unix &
export DISPLAY=:99

if [ "$1" = "gateway" ]; then
    /port-forwarding.sh &
    su-exec ibgateway /opt/ibc/gatewaystart.sh -inline

else
    exec "$@"
fi
