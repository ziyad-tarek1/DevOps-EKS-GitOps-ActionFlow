
#!/bin/bash
# Update the package list and upgrade all packages
sudo apt-get update -y
sudo apt-get upgrade -y
# Install AWS CLI 
sudo snap install aws-cli --classic
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# sudo apt-get install unzip -y
# unzip awscliv2.zip
# sudo ./aws/install

# Install docker
sudo apt-get update
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu
newgrp docker
sudo chmod 777 /var/run/docker.sock

