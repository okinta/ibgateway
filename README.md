# IBGateway

Runs [Interactive Brokers (IB) Gateway][1] as a container.

This makes use of [IBC][2] for automating interaction with IB Gateway.

The container is published to [Docker Hub][3] under `okinta/ibgateway`.

    docker pull okinta/ibgateway

[1]: https://www.interactivebrokers.com/en/index.php?f=16457
[2]: https://github.com/IbcAlpha/IBC
[3]: https://hub.docker.com/r/okinta/ibgateway

## Building

To build the container:

    docker build -t okinta/ibgateway .

## Running

To run the container, the following environment variables need to be set:

* LOGIN: The user ID for IB.
* PASSWORD: The password for IB.

If `MODE` is not set, it will default to `paper`. `MODE` must be set to either
`live` or `paper`. `paper` indicates IB paper trading mode, and `live`
indicates trading with real money.

    docker run -e "LOGIN=[login]" -e "PASSWORD=[password]" -e MODE=paper -p 7000:7000 okinta/ibgateway

After the container has started, the IB API will be available via port 7000.
