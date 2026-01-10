FROM jenkins/inbound-agent:jdk17

USER root

# Install prerequisites
RUN apt-get update && \
    apt-get install -y curl ca-certificates gnupg lsb-release

# Add Docker's official GPG key
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CLI + Compose
RUN apt-get update && \
    apt-get install -y docker-ce-cli && \
    curl -SL https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-linux-x86_64 \
      -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

USER jenkins