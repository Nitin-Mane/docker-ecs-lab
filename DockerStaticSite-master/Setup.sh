#!/bin/bash

# Update the system and install necessary packages
sudo yum update -y
sudo yum install -y docker git

# Start Docker service
sudo service docker start

# Add the current user to the docker group for non-root access
sudo usermod -a -G docker ec2-user

# Configure Docker security
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --iptables=false --ip-masq=false
EOF

# Reload the Docker daemon and restart Docker service
sudo systemctl daemon-reload
sudo systemctl restart docker

# Set up a basic CI check for the container
if docker build -t my-container . && docker run my-container; then
  echo "Docker container built and tested successfully."
  exit 0
else
  echo "Docker container build or test failed."
  exit 1
fi
