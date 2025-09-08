#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
             
# Add the 'ubuntu' user to the 'docker' group.
sudo usermod -aG docker ubuntu

# Apply the new group membership to the current shell session.
# This avoids the need to log out and back in.
sudo newgrp docker

# Pull and run the Docker image from Docker Hub.
sudo docker run -d -p 5000:5000 --name hello-app khingarthur/hello-world-app:latest
