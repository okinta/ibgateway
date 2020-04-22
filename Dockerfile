ARG UBUNTU_VERSION=18.04
FROM ubuntu:$UBUNTU_VERSION

# Install tools to install other tools
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    ca-certificates \
    unzip \
    wget

# Install gettext for envsubst
RUN apt-get install --no-install-recommends -y gettext-base \
    && mkdir -p /deps/usr/bin \
    && cp /usr/bin/envsubst /deps/usr/bin

# Install tini just for some extra safety in case there are any zombies
ARG TINI_VERSION=0.19.0
RUN wget -q https://github.com/krallin/tini/releases/download/v$TINI_VERSION/tini-amd64 \
    && chmod o+x tini-amd64 \
    && mkdir -p /deps/usr/local/bin \
    && mv tini-amd64 /deps/usr/local/bin/tini

# Install IBC
ARG IBC_VERSION=3.8.2
RUN wget -q https://github.com/IbcAlpha/IBC/releases/download/$IBC_VERSION/IBCLinux-$IBC_VERSION.zip \
    && mkdir -p /deps/opt \
    && unzip IBCLinux-$IBC_VERSION.zip -d /deps/opt/ibc \
    && chmod o+x /deps/opt/ibc/*.sh /deps/opt/ibc/*/*.sh

# Install curl so we can download dependencies that we don't add here
COPY --from=okinta/curl-static:ubuntu /curl /deps

FROM ubuntu:$UBUNTU_VERSION

# Install dependencies
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    libxi6 \
    libxrender1 \
    libxtst6 \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Create a new user to run IB Gateway under
RUN useradd --create-home ibgateway

# Pull in what we need from the builder container
COPY --from=0 /deps /

# Install IB Gateway
RUN curl -s -O https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh \
    && chmod o+x ibgateway-stable-standalone-linux-x64.sh \
    && su ibgateway -c 'yes n | ./ibgateway-stable-standalone-linux-x64.sh' \
    && rm -f ibgateway-stable-standalone-linux-x64.sh

USER ibgateway
COPY files /home/ibgateway
COPY displaybannerandlaunch.sh /opt/ibc/scripts
ENTRYPOINT ["/usr/local/bin/tini", "--", "/home/ibgateway/entrypoint.sh"]
CMD ["gateway"]
