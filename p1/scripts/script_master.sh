#!/bin/bash

set -x

sudo apt-get update

sudo apt-get install -y curl
# Installer K3s en tant que serveur maître avec un nom de nœud spécifique 
curl -sSL https://get.k3s.io | sh -s - server --node-ip 192.168.56.110 --node-name hbelleS
# Copier le fichier kubeconfig pour l'accès externe
sudo cp /etc/rancher/k3s/k3s.yaml /vagrant/confs/kubeconfig
# Modifier l'adresse IP dans le fichier kubeconfig
sed -i "s/127\\.0\\.0\\.1/192.168.56.110/" /vagrant/confs/kubeconfig
# Extraire le token pour les agents
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/confs/node-token