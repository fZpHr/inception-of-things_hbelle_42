#!/bin/bash

set -x
sudo apt-get update
sudo apt-get install -y curl
# Installer K3s en tant que serveur maître avec un nom de nœud spécifique
curl -sSL https://get.k3s.io | sh -s - server --node-ip 192.168.56.110 --node-name hbelleS

# Copier le fichier kubeconfig pour l'accès externe
sudo cp /etc/rancher/k3s/k3s.yaml /vagrant/conf/kubeconfig

# Modifier l'adresse IP dans le fichier kubeconfig
sed -i "s/127\\.0\\.0\\.1/192.168.56.110/" /vagrant/conf/kubeconfig

# Déploiement des services
sudo kubectl apply -f /vagrant/conf/app1/service-app1.yaml
sudo kubectl apply -f /vagrant/conf/app2/service-app2.yaml
sudo kubectl apply -f /vagrant/conf/app3/service-app3.yaml

# Attente de 30 secondes pour que les services soient prêts
sleep 30

# Déploiement des pods
sudo kubectl apply -f /vagrant/conf/app1/deployment-app1.yaml
sudo kubectl apply -f /vagrant/conf/app2/deployment-app2.yaml
sudo kubectl apply -f /vagrant/conf/app3/deployment-app3.yaml

# Déploiement de l'ingress
sudo kubectl apply -f /vagrant/conf/ingress.yaml

# attendre 30 secondes pour que les pods soient prêts
sleep 30

# Obtenir les noms des pods et les versions des systèmes d'exploitation
chmod +x /vagrant/scripts/script_html_app1.sh
chmod +x /vagrant/scripts/script_html_app2.sh
chmod +x /vagrant/scripts/script_html_app3.sh
bash /vagrant/scripts/script_html_app1.sh
bash /vagrant/scripts/script_html_app2.sh
bash /vagrant/scripts/script_html_app3.sh