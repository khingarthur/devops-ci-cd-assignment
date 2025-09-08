#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
              
# Pull and run the Docker image from Docker Hub.
sudo usermod -aG docker ubuntu
sudo docker run -d -p 5000:5000 --name hello-app khingarthur/hello-world-app:latest