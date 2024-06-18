#!/bin/bash

# Update package list
sudo apt update -y

sudo apt install openjdk-11-jdk -y

# Install necessary certificates and curl
sudo apt install ca-certificates curl -y

# Create keyrings directory for Docker and fetch the GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to APT sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list again to include Docker packages
sudo apt update -y

# Install Docker packages
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Add current user to Docker group
sudo usermod -aG docker $USER

# Apply the new group membership immediately
newgrp docker << END

# Verify Docker installation
docker --version

# Ensure Docker service is running and enabled
sudo systemctl status docker
sudo systemctl start docker
sudo systemctl enable docker

# Install additional dependencies
sudo apt install -y curl wget apt-transport-https

# Download and install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64
minikube version

# Download and install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version -o yaml

END
