#!/bin/bash

# This script installs Docker and Docker Compose on an Ubuntu system

# Update package list and upgrade all packages
sudo apt-get update
sudo apt-get upgrade -y

# Install prerequisites
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker's APT repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update package list again
sudo apt-get update

# Install Docker CE
sudo apt-get install -y docker-ce

# Enable Docker to start at boot
sudo systemctl enable docker

# Start Docker service
sudo systemctl start docker

# Download the latest version of Docker Compose
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Apply executable permissions to the Docker Compose binary
sudo chmod +x /usr/local/bin/docker-compose

# Add current user to the docker group
sudo usermod -aG docker $USER

# Apply the new group membership without logout/login
newgrp docker

# Print versions to verify installation
docker --version
docker-compose --version

echo "Docker and Docker Compose have been installed successfully."
echo "Please log out and log back in to ensure your user is properly added to the 'docker' group."
