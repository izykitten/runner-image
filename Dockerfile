FROM docker.io/nestybox/ubuntu-noble-systemd-docker

# Enable docker to start on boot via systemd (manual symlink since systemd isn't running at build time)
RUN ln -sf /lib/systemd/system/docker.service /etc/systemd/system/multi-user.target.wants/docker.service

# Configure docker to listen on TCP without TLS
RUN mkdir -p /etc/docker && \
    echo '{"hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"], "tls": false}' > /etc/docker/daemon.json && \
    mkdir -p /etc/systemd/system/docker.service.d && \
    echo '[Service]\nExecStart=\nExecStart=/usr/bin/dockerd' > /etc/systemd/system/docker.service.d/override.conf

# Set DOCKER_HOST for convenience
ENV DOCKER_HOST=unix:///var/run/docker.sock

# Default to systemd as init
ENTRYPOINT ["/sbin/init"]
