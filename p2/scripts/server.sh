#!/bin/bash

#set -x

export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt install curl -y

sudo ip addr flush dev eth1
sudo ip addr add $1/24 dev eth1
sudo ip link set eth1 up

export INSTALL_K3S_EXEC="server --write-kubeconfig-mode=644 --node-ip $1"

echo "Installing k3s as controller"

curl -sfL https://get.k3s.io | sh -

#cp /var/lib/rancher/k3s/server/token /vagrant/k3s_token
echo "CURRENT_IP=$(ip a show eth1 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)"
echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh

echo "k3s controller installed"
