# README

Runs Interactive Brokers (IB) gateway.

## Building

To build the container:

    docker build -t okinta/stack-ibgateway .

## Running

To run the container, the following environment variables need to be set:

* LOGIN: The user ID for IB.
* PASSWORD: The password for IB.

If `MODE` is not set, it will default to `paper`. `MODE` must be set to either
`live` or `paper`. `paper` indicates IB paper trading mode, and `live`
indicates trading with real money.

    docker run -e "LOGIN=[login]" -e "PASSWORD=[password]" -e MODE=paper -v logs:/root/ibc/logs okinta/stack-ibgateway
