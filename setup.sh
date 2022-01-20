#!/bin/bash

DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:=v2.2.3}
SYSTEM=$(uname -s)
ARCHITECTURE=$(uname -m)

# Install apt packages
sudo apt update
sudo apt -y upgrade
sudo apt install -y python3-pip zsh htop git curl tldr

# Make snap work under WSL2
git clone https://github.com/DamionGans/ubuntu-wsl2-systemd-script.git $USER/ubuntu-wsl2-systemd-script
$USER/ubuntu-wsl2-systemd-script/ubuntu-wsl2-systemd-script.sh --force

# Set ZSH as default shell
sudo usermod -s /usr/bin/zsh $(whoami)

# Install Antigen (ZSH plugin manager)
curl -L git.io/antigen > ~/.antigen.zsh

# Copy configuration scripts
cp .zshrc ~/.zshrc
cp .antigenrc ~/.antigenrc
cp .p10k.zsh ~/.p10k.zsh

sudo cp resources/etc/wsl.conf /etc/wsl.conf

sudo bash -c "echo '[user]' >> /etc/wsl.conf"
sudo bash -c "echo 'default=${USER}' >> /etc/wsl.conf"

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-${SYSTEM,,}-${ARCHITECTURE,,}" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo groupadd docker
sudo usermod -aG docker $USER

# Allow to run docker daemon without sudo
sudo echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/dockerd" | (sudo su -c 'EDITOR="tee" visudo -f /etc/sudoers.d/docker')
