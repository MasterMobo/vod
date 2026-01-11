#!/bin/bash

# Update the system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Git
sudo apt-get install -y git

# Install Docker
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add the 'ubuntu' and 'ssm-user' to the Docker group
sudo usermod -aG docker ubuntu
sudo newgrp docker

# Enable and start Docker
sudo systemctl enable docker.service
sudo systemctl start docker.service

# Install Docker Compose v2
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.40.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Clone code base
if [ -d "vod" ]; then rm -rf vod; fi  # Fresh code base
git clone https://github.com/MasterMobo/vod
cd vod

# Start app
docker compose pull
docker compose up -d