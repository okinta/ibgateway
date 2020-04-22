FROM ubuntu:18.04

# Install TWS Gateway
RUN apt-get update && apt-get install -y wget \
    && wget -q https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh \
    && chmod +x ibgateway-stable-standalone-linux-x64.sh \
    && yes n | ./ibgateway-stable-standalone-linux-x64.sh \
    && apt-get remove -y --purge wget \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install IBC
ARG IBC_VERSION=3.8.2
RUN apt-get update && apt-get install -y unzip wget \
    && wget -q https://github.com/IbcAlpha/IBC/releases/download/$IBC_VERSION/IBCLinux-$IBC_VERSION.zip \
    && unzip IBCLinux-$IBC_VERSION.zip -d /opt/ibc \
    && chmod o+x /opt/ibc/*.sh /opt/ibc/*/*.sh \
    && apt-get remove -y --purge unzip wget \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*
COPY config.ini /root/config.ini.template

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/opt/ibc/gatewaystart.sh"]
