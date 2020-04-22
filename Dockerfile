ARG UBUNTU_VERSION=18.04
FROM ubuntu:$UBUNTU_VERSION
RUN apt-get update && apt-get install -y gettext-base

FROM ubuntu:$UBUNTU_VERSION

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
COPY config.ini /root/ibc/config.ini.template
RUN mkdir /root/ibc/logs

# Grab wait-for-it script so we know when gateway is ready
RUN apt-get update && apt-get install -y unzip wget \
    && wget -q https://raw.githubusercontent.com/vishnubob/wait-for-it/c096cface5fbd9f2d6b037391dfecae6fde1362e/wait-for-it.sh -O /wait-for-it.sh \
    && chmod +x /wait-for-it.sh \
    && apt-get remove -y --purge wget \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY --from=0 /usr/bin/envsubst /usr/bin/envsubst
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["gateway"]
