#!/bin/bash

set -x
sudo apt-get update
sudo apt-get install -y curl

curl -sSL https://get.k3s.io | sh -s - server --node-ip 192.168.56.110 --node-name hbelleS

sudo cp /etc/rancher/k3s/k3s.yaml /vagrant/confs/kubeconfig

sed -i "s/127\\.0\\.0\\.1/192.168.56.110/" /vagrant/confs/kubeconfig

sudo kubectl apply -f /vagrant/confs/app1/service-app1.yaml
sudo kubectl apply -f /vagrant/confs/app2/service-app2.yaml
sudo kubectl apply -f /vagrant/confs/app3/service-app3.yaml

sleep 30

sudo kubectl apply -f /vagrant/confs/app1/deployment-app1.yaml
sudo kubectl apply -f /vagrant/confs/app2/deployment-app2.yaml
sudo kubectl apply -f /vagrant/confs/app3/deployment-app3.yaml

sudo kubectl apply -f /vagrant/confs/ingress.yaml

sleep 30

chmod +x /vagrant/scripts/script_html_app1.sh
chmod +x /vagrant/scripts/script_html_app2.sh
chmod +x /vagrant/scripts/script_html_app3.sh
bash /vagrant/scripts/script_html_app1.sh
bash /vagrant/scripts/script_html_app2.sh
bash /vagrant/scripts/script_html_app3.sh