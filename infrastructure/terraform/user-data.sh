#!/bin/bash
set -e

# Update system
sudo dnf update -y

# Docker is already installed on ECS-optimized AMIs
sudo systemctl enable docker
sudo systemctl start docker

# Allow ec2-user to run docker
sudo usermod -aG docker ec2-user

# Install Docker Compose v2 plugin
sudo mkdir -p /usr/local/lib/docker/cli-plugins

sudo curl -SL https://github.com/docker/compose/releases/download/v2.25.0/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Verify
sudo docker --version
sudo docker compose version

# Install Git
sudo dnf install -y git

# Create app directory
sudo mkdir -p /opt/vod
sudo chown ec2-user:ec2-user /opt/vod