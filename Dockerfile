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
RUN mkdir -p /deps/usr/local/bin \
    && wget -q -O /deps/usr/local/bin/tini https://s3.okinta.ge/tini-amd64-0.19.0 \
    && chmod o+x /deps/usr/local/bin/tini

# Install IBC
RUN wget -q -O IBCLinux.zip https://s3.okinta.ge/IBCLinux-3.8.2.zip \
    && mkdir -p /deps/opt \
    && unzip IBCLinux.zip -d /deps/opt/ibc \
    && rm -f IBCLinux.zip \
    && chmod o+x /deps/opt/ibc/*.sh /deps/opt/ibc/*/*.sh

# Grab wait-for-it script so we know when gateway is ready
RUN wget -q -O wait-for-it.zip \
        https://s3.okinta.ge/wait-for-it-c096cface5fbd9f2d6b037391dfecae6fde1362e.zip \
    && unzip wait-for-it.zip \
    && rm -f wait-for-it.zip \
    && mkdir -p /deps/usr/local/bin \
    && mv wait-for-it-master/wait-for-it.sh /deps/usr/local/bin/wait-for-it \
    && chmod o+x /deps/usr/local/bin/wait-for-it

# Build su-exec so we can switch users easily
ARG SU_EXEC_VERSION=212b75144bbc06722fbd7661f651390dc47a43d1
RUN apt-get install --no-install-recommends -y build-essential \
    && wget -q -O su-exec.zip \
        https://s3.okinta.ge/su-exec-$SU_EXEC_VERSION.zip \
    && unzip su-exec.zip \
    && rm -f su-exec.zip \
    && cd su-exec-$SU_EXEC_VERSION \
    && make \
    && cp su-exec /deps/usr/local/bin \
    && chmod o+x /deps/usr/local/bin/su-exec

FROM ubuntu:$UBUNTU_VERSION

# Install dependencies
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    ca-certificates \
    libxi6 \
    libxrender1 \
    libxtst6 \
    socat \
    wget \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Create a new user to run IB Gateway under
RUN useradd --create-home ibgateway

# Pull in what we need from the builder container
COPY --from=0 /deps /

# Install IB Gateway
RUN set -x \
    && wget -q -O install-ibgateway.sh \
        https://s3.okinta.ge/ibgateway-972-standalone-linux-x64.sh \
    && chmod o+x install-ibgateway.sh \
    && su ibgateway -c 'yes n | ./install-ibgateway.sh' \
    && rm -f install-ibgateway.sh

COPY files /
RUN chown -R ibgateway:ibgateway /home/ibgateway \
    && chmod o+x /*.sh /opt/ibc/scripts/*.sh

EXPOSE 7000
ENTRYPOINT ["/usr/local/bin/tini", "--", "/entrypoint.sh"]
CMD ["gateway"]
