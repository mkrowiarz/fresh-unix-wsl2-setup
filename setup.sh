#!/bin/bash

DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:=v2.2.3}
SYSTEM=$(uname -s)
ARCHITECTURE=$(uname -m)
HOMEDIR=$(sudo -u $USER sh -c 'echo $HOME')

# Install apt packages
sudo apt update
sudo apt upgrade
sudo apt install -y python3-pip zsh htop git curl tldr

# Make snap work under WSL2
sudo apt-get update && sudo apt-get install -yqq daemonize dbus-user-session fontconfig && \
sudo daemonize /usr/bin/unshare --fork --pid --mount-proc /lib/systemd/systemd --system-unit=basic.target exec sudo nsenter -t $(pidof systemd) -a su - $LOGNAME

sudo snap install phpstorm --classic

# Set ZSH as default shell
sudo usermod -s /usr/bin/zsh $(whoami)

# Install Antigen (ZSH plugin manager)
curl -L git.io/antigen > ${HOMEDIR}/.antigen.zsh

# Copy configuration scripts
cp .zshrc ${HOMEDIR}/.zshrc
cp .antigenrc ${HOMEDIR}./.antigenrc
cp .p10k.zsh ${HOMEDIR}/.p10k.zsh

antigen theme spaceship-prompt/spaceship-prompt

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-${SYSTEM,,}-${ARCHITECTURE,,}" -o /usr/local/bin/docker-compose
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
