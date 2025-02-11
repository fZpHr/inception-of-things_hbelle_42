#!/bin/bash

set -e  # Arrête le script en cas d'erreur

# Couleurs
BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'
GRAY='\033[90m'
RED='\033[31m'
NC='\033[0m'

# Vérifier si le cluster existe et le supprimer
if k3d cluster list | grep -q "^p3 "; then
    echo -e "${RED}Deleting k3d cluster 'p3'...${NC}"
    k3d cluster delete p3
else
    echo -e "${YELLOW}Cluster 'p3' does not exist.${NC}"
fi

# Vérifier que le cluster a bien été supprimé
if k3d cluster list | grep -q "^p3 "; then
    echo -e "${RED}Failed to delete k3d cluster 'p3'.${NC}"
    exit 1
else
    echo -e "${GREEN}k3d cluster 'p3' successfully deleted.${NC}"
fi

# Vérifier si le namespace argocd existe et le supprimer
if kubectl get namespace argocd &> /dev/null; then
    echo -e "${RED}Deleting namespace 'argocd'...${NC}"
    kubectl delete namespace argocd
else
    echo -e "${YELLOW}Namespace 'argocd' does not exist.${NC}"
fi

# Vérifier que le namespace argocd a bien été supprimé
if kubectl get namespace argocd &> /dev/null; then
    echo -e "${RED}Failed to delete namespace 'argocd'.${NC}"
    exit 1
else
    echo -e "${GREEN}Namespace 'argocd' successfully deleted.${NC}"
fi

# Vérifier si le namespace dev existe et le supprimer
if kubectl get namespace dev &> /dev/null; then
    echo -e "${RED}Deleting namespace 'dev'...${NC}"
    kubectl delete namespace dev
else
    echo -e "${YELLOW}Namespace 'dev' does not exist.${NC}"
fi

# Vérifier que le namespace dev a bien été supprimé
if kubectl get namespace dev &> /dev/null; then
    echo -e "${RED}Failed to delete namespace 'dev'.${NC}"
    exit 1
else
    echo -e "${GREEN}Namespace 'dev' successfully deleted.${NC}"
fi

if [ -f ~/tmp/p3 ]; then
    echo -e "${BLUE}Deleting p3 indic...${NC}"
    rm -f ~/tmp/p3
fi

echo -e "${GREEN}Cleanup script completed successfully.${NC}"