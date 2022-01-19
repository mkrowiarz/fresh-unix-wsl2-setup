#!/bin/bash


DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:=1.29.2}

# Install apt packages
sudo apt update
sudo apt upgrade
sudo apt install -y python3-pip zsh htop git curl tldr

# Set ZSH as default shell
sudo usermod -s /usr/bin/zsh $(whoami)

# Install Antigen (ZSH plugin manager)
curl -L git.io/antigen > ~/.antigen.zsh

# Copy configuration scripts
cp .zshrc ~/.zshrc
cp .antigenrc ~/.antigenrc
cp .p10k.zsh ~/.p10k.zsh

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo curl -L "https://github.com/docker/compose/releases/download/v{$DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo groupadd docker
sudo usermod -aG docker $USER

# Allow to run docker daemon without sudo
sudo echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/dockerd" | (sudo su -c 'EDITOR="tee" visudo -f /etc/sudoers.d/docker')

DOCKER_DIR=/mnt/wsl/shared-docker
mkdir -pm o=,ug=rwx "$DOCKER_DIR"
chgrp docker "$DOCKER_DIR"

sudo mkdir -p /etc/docker/
cp resources/etc/docker/daemon.json /etc/docker/daemon.json

echo '# Start Docker daemon automatically when logging in if not running.' >> ~/.zshrc
echo 'RUNNING=`ps aux | grep dockerd | grep -v grep`' >> ~/.zshrc
echo 'if [ -z "$RUNNING" ]; then' >> ~/.zshrc
echo '    sudo dockerd > /dev/null 2>&1 &' >> ~/.zshrc
echo '    disown' >> ~/.zshrc
echo 'fi' >> ~/.zshrc
