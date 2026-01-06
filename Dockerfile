FROM docker.io/nestybox/ubuntu-noble-systemd-docker

# Install common build tools and utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    make \
    openssh-client \
    unzip \
    wget \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Enable docker to start on boot via systemd (manual symlink since systemd isn't running at build time)
RUN ln -sf /lib/systemd/system/docker.service /etc/systemd/system/multi-user.target.wants/docker.service

# Set DOCKER_HOST for convenience
ENV DOCKER_HOST=unix:///var/run/docker.sock

# Default to systemd as init
ENTRYPOINT ["/sbin/init"]
