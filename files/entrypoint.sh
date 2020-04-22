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
    exit
fi

envsubst < ~/ibc/config.ini.template > ~/ibc/config.ini

if [ $@ = "gateway" ]; then
    /opt/ibc/gatewaystart.sh

    port=4001
    if [ "$MODE" = paper ]; then
        port=4002
    fi
    wait-for-it 127.0.0.1:$port -t 30 -s -- echo "Gateway is running"

else
    exec "$@"
fi
