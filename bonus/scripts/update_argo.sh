#!/bin/bash

# kubectl get pods -n gitlab -o wide

IP=$(kubectl get pods -n gitlab -o wide | awk {'print $6'} | grep 10)
kubectl get pods -n gitlab -o wide

sed -i "s|repoURL: 'http://.*|repoURL: 'http://$IP/root/test.git'|" ../confs/argocd.yaml
sed -i "s|url: .*|url: 'http://$IP/root/test.git'|" ../confs/gitlab-secret.yaml


NODE_IPS=$(kubectl get nodes -o wide | awk '{print $6}' | grep -v INTERNAL-IP)
git clone http://$NODE_IPS:30081/root/test.git repo


cp -R ../../p3 repo/ && cd repo
git add .
git commit -m "update"
git push http://root:new_password@$NODE_IPS:30081/root/test.git

cd ..

kubectl apply -f ../confs/argocd.yaml
kubectl apply -f ../confs/gitlab-secret.yaml

rm -rf repo