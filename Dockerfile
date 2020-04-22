ARG UBUNTU_VERSION=18.04
FROM ubuntu:$UBUNTU_VERSION

# Install gettext for envsubst
RUN apt-get update && apt-get install -y gettext-base

# Install tini
RUN apt-get install -y wget
ARG TINI_VERSION=0.19.0
RUN wget -q https://github.com/krallin/tini/releases/download/v$TINI_VERSION/tini-amd64 \
    -O /usr/local/bin/tini \
    && chmod +x /usr/local/bin/tini

# Keep file structure for dependencies so that we can easily copy them
RUN mkdir -p /deps/usr/bin && cp /usr/bin/envsubst /deps/usr/bin/envsubst \
    && mkdir -p /deps/usr/local/bin && cp /usr/local/bin/tini /deps/usr/local/bin/tini

FROM ubuntu:$UBUNTU_VERSION

# Install IB Gateway
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

# Grab wait-for-it script so we know when gateway is ready
RUN apt-get update && apt-get install -y wget \
    && wget -q https://raw.githubusercontent.com/vishnubob/wait-for-it/c096cface5fbd9f2d6b037391dfecae6fde1362e/wait-for-it.sh -O /usr/local/bin/wait-for-it \
    && chmod +x /usr/local/bin/wait-for-it \
    && apt-get remove -y --purge wget \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN apt-get update \
    && apt-get install --no-install-recommends -y xfonts-base \
    && apt-get install --no-install-recommends -y xterm \
    && apt-get install --no-install-recommends -y xvfb \
    && rm -rf /var/lib/apt/lists/*
COPY --from=0 /deps /

# Create a new user to run IB Gateway under
ARG IBUSER=ibgateway
COPY files /home/ibgateway
RUN useradd ibgateway \
    && chown -R ibgateway:ibgateway /home/ibgateway

USER ibgateway
ENTRYPOINT ["/usr/local/bin/tini", "--", "/home/ibgateway/entrypoint.sh"]
CMD ["gateway"]
