#!/bin/bash

set -x

sudo apt-get update

sudo apt-get install -y curl

curl -sSL https://get.k3s.io | sh -s - server --node-ip 192.168.56.110 --node-name hbelleS

sudo cp /etc/rancher/k3s/k3s.yaml /vagrant/confs/kubeconfig

sed -i "s/127\\.0\\.0\\.1/192.168.56.110/" /vagrant/confs/kubeconfig

sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/confs/node-token