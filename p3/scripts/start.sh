#!/bin/bash

set -e  # Arrête le script en cas d'erreur

# Vérifier si le cluster existe déjà
if k3d cluster list | grep -q "^p3 "; then
    echo "Cluster 'p3' already exists."
else
    echo "Creating k3d cluster..."
    k3d cluster create p3
fi

# Vérifier si le namespace argocd existe déjà
if kubectl get namespace argocd &> /dev/null; then
    echo "Namespace 'argocd' already exists."
else
    echo "Creating namespace for ArgoCD..."
    kubectl create namespace argocd
fi

# Vérifier si ArgoCD est déjà installé
if kubectl get deployments -n argocd | grep -q "argocd-server"; then
    echo "ArgoCD is already installed."
else
    echo "Installing ArgoCD..."
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    # Attendre que ArgoCD soit prêt
    echo "Waiting for ArgoCD to be ready..."
    kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
fi

# Vérifier si le namespace dev existe déjà
if kubectl get namespace dev &> /dev/null; then
    echo "Namespace 'dev' already exists."
else
    echo "Creating namespace for the application..."
    kubectl create namespace dev
fi

# Vérifier si l'application ArgoCD existe déjà
if kubectl get applications -n argocd | grep -q "argocd-application"; then
    echo "ArgoCD application is already configured."
else
    echo "Applying ArgoCD application configuration..."
    kubectl apply -n argocd -f ../conf/argocd.yaml
fi

echo "Script completed successfully."