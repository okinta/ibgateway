#!/usr/bin/env bash

read -r IBC_VRSN < "${IBC_PATH}/version"
export IBC_VRSN

echo "Running IB Gateway ${TWS_MAJOR_VRSN}"

exec "${IBC_PATH}/scripts/ibcstart.sh" "${TWS_MAJOR_VRSN}" "-g" \
    "--tws-path=${TWS_PATH}" "--tws-settings-path=${TWS_SETTINGS_PATH}" \
    "--ibc-path=${IBC_PATH}" "--ibc-ini=${IBC_INI}" \
    "--user=${TWSUSERID}" "--pw=${TWSPASSWORD}" "--fix-user=${FIXUSERID}" \
    "--fix-pw=${FIXPASSWORD}" "--java-path=${JAVA_PATH}" \
    "--mode=${TRADING_MODE}"
