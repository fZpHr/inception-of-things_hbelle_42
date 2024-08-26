#!/bin/bash

set -e  # Arrête le script en cas d'erreur

# Vérifier si le cluster existe et le supprimer
if k3d cluster list | grep -q "^p3 "; then
    echo "Deleting k3d cluster 'p3'..."
    k3d cluster delete p3
else
    echo "Cluster 'p3' does not exist."
fi

# Vérifier que le cluster a bien été supprimé
if k3d cluster list | grep -q "^p3 "; then
    echo "Failed to delete k3d cluster 'p3'."
    exit 1
else
    echo "k3d cluster 'p3' successfully deleted."
fi

# Vérifier si le namespace argocd existe et le supprimer
if kubectl get namespace argocd &> /dev/null; then
    echo "Deleting namespace 'argocd'..."
    kubectl delete namespace argocd
else
    echo "Namespace 'argocd' does not exist."
fi

# Vérifier que le namespace argocd a bien été supprimé
if kubectl get namespace argocd &> /dev/null; then
    echo "Failed to delete namespace 'argocd'."
    exit 1
else
    echo "Namespace 'argocd' successfully deleted."
fi

# Vérifier si le namespace dev existe et le supprimer
if kubectl get namespace dev &> /dev/null; then
    echo "Deleting namespace 'dev'..."
    kubectl delete namespace dev
else
    echo "Namespace 'dev' does not exist."
fi

# Vérifier que le namespace dev a bien été supprimé
if kubectl get namespace dev &> /dev/null; then
    echo "Failed to delete namespace 'dev'."
    exit 1
else
    echo "Namespace 'dev' successfully deleted."
fi

echo "Cleanup script completed successfully."