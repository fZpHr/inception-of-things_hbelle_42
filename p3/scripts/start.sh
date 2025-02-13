#!/bin/bash

set -e

BLUE='\033[34m'
GREEN='\033[32m'
PURPLE='\033[35m'
YELLOW='\033[33m'
GRAY='\033[90m'
RED='\033[31m'
NC='\033[0m'

execute() {
    echo -e "${GRAY}$1${NC}"
    eval $1
}

if k3d cluster list | grep -q "^p3 "; then
    echo -e "${YELLOW}Cluster 'p3' already exists.${NC}"
else
    echo -e "${BLUE}Creating k3d cluster...${NC}"
    if ! execute "k3d cluster create p3"; then
        echo -e "${RED}Failed to create k3d cluster.${NC}"
        exit 1
    fi
fi

if execute "kubectl get namespace argocd &> /dev/null"; then
    echo -e "${YELLOW}Namespace 'argocd' already exists.${NC}"
else
    echo -e "${BLUE}Creating namespace for ArgoCD...${NC}"
    if ! execute "kubectl create namespace argocd"; then
        echo -e "${RED}Failed to create namespace 'argocd'.${NC}"
        exit 1
    fi
fi

if execute "kubectl get deployments -n argocd | grep -q 'argocd-server'"; then
    echo -e "${YELLOW}ArgoCD is already installed.${NC}"
else
    echo -e "${BLUE}Installing ArgoCD...${NC}"
    if ! execute "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"; then
        echo -e "${RED}Failed to install ArgoCD.${NC}"
        exit 1
    fi

    echo -e "${BLUE}Waiting for ArgoCD to be ready...${NC}"
    if ! execute "kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s"; then
        echo -e "${RED}ArgoCD is not ready after waiting.${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}Applying ArgoCD server configuration...${NC}"
if ! execute "kubectl apply -f ../confs/argocd-server.yaml"; then
    echo -e "${RED}Failed to apply ArgoCD server configuration.${NC}"
    exit 1
fi

if execute "kubectl get namespace dev &> /dev/null"; then
    echo -e "${YELLOW}Namespace 'dev' already exists.${NC}"
else
    echo -e "${BLUE}Creating namespace for the application...${NC}"
    if ! execute "kubectl create namespace dev"; then
        echo -e "${RED}Failed to create namespace 'dev'.${NC}"
        exit 1
    fi
fi

if execute "kubectl get applications -n argocd | grep -q 'argocd-application'"; then
    echo -e "${YELLOW}ArgoCD application is already configured.${NC}"
else
    echo -e "${BLUE}Applying ArgoCD application configuration...${NC}"
    if ! execute "kubectl apply -n argocd -f ../confs/argocd.yaml"; then
        echo -e "${RED}Failed to apply ArgoCD application configuration.${NC}"
        exit 1
    fi
fi

mkdir -p ~/tmp
touch ~/tmp/p3

IP_ARGO=$(kubectl get node -o wide | awk 'NR==2 {print $6}')
while ! kubectl -n argocd get secret argocd-initial-admin-secret > /dev/null 2>&1; do
  echo "Secret not found, retrying in 5 seconds..."
  sleep 5
done
PSSWD_ARGO=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
echo -e "${GREEN}Script completed successfully. Access ArgoCD at ${PURPLE}https://$IP_ARGO:30080${GREEN}, id: ${PURPLE}admin${GREEN},  password: ${PURPLE}$PSSWD_ARGO${GREEN}"
echo -e "${GREEN}Access the application at ${PURPLE}http://$IP_ARGO:30088${NC}"

#sudo kubectl get pods -n dev
#sudo kubectl port-forward pod/nom_du_pod -n dev 8888:8888