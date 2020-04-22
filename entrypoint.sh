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

if [ ! "$MODE" =~ ^(live|paper)$ ]; then
    echo "MODE environment variable must be set to either live or paper" >&2
    exit
fi

envsubst < /root/config.ini.template > /root/config.ini

exec "$@"
