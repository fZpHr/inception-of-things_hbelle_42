#!/bin/bash

kubectl get pods -n gitlab -o wide
kubectl apply -f ../confs/argocd.yaml
kubectl apply -f ../confs/gitlab-secret.yaml