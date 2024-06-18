#!/bin/bash

# Update package list
sudo apt update

# Install dependencies
sudo apt install -y curl wget apt-transport-https

# Install Docker
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Download and install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Download and install kubectl
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Start Minikube with specified resources
minikube start --addons=ingress --cpus=3 --cni=flannel --install-addons=true --kubernetes-version=stable --memory=10g

# Enable Minikube addons
minikube addons enable csi-hostpath-driver
minikube addons enable efk
minikube addons enable helm-tiller
minikube addons enable ingress-dns
minikube addons enable metrics-server
minikube addons enable pod-security-policy
minikube addons enable storage-provisioner
minikube addons enable volumesnapshots

# Start Minikube dashboard in background
(minikube dashboard --url &) &>/dev/null
