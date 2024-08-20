#!/bin/bash

set -x
echo "Updating package list..."
sudo apt-get update
echo "Installing curl..."
sudo apt-get install -y curl
echo "Waiting for node-token file..."
while [ ! -f /vagrant/node-token ]; do sleep 1; done
echo "node-token file found. Attempting to join the cluster..."
K3S_TOKEN=$(cat /vagrant/node-token)
echo "K3S_TOKEN: $K3S_TOKEN"
while true; do
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$K3S_TOKEN sh -s - agent --node-ip 192.168.56.111 --node-name hbelleSW
if [ $? -eq 0 ]; then
    echo "Successfully joined the cluster."
    break
else
    echo "Failed to join the cluster. Retrying in 2 seconds..."
    sleep 2
fi
done