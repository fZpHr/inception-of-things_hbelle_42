#!/bin/bash

set -e

BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'
GRAY='\033[90m'
RED='\033[31m'
NC='\033[0m'


delete_p3() {
    cd ../../p3/scripts
    if [ -f delete.sh ]; then
        echo -e "${BLUE}Running delete.sh script...${NC}"
        bash delete.sh
    else
        echo -e "${YELLOW}delete.sh script not found.${NC}"
    fi
    cd -
}

delete_bonus() {

    if kubectl get namespace gitlab &> /dev/null; then
        echo -e "${RED}Deleting namespace 'gitlab'...${NC}"
        kubectl delete namespace gitlab
    else
        echo -e "${YELLOW}Namespace 'gitlab' does not exist.${NC}"
    fi

    k3d cluster delete p3
    docker system prune -af
    docker volume prune -f
    docker network prune -f


    rm -f ~/.kube/config

    if k3d cluster list | grep -q "^p3 "; then
        echo -e "${RED}Deleting k3d cluster 'p3'...${NC}"
        k3d cluster delete p3
    else
        echo -e "${YELLOW}Cluster 'p3' does not exist.${NC}"
    fi

    if k3d cluster list | grep -q "^p3 "; then
        echo -e "${RED}Failed to delete k3d cluster 'p3'.${NC}"
        exit 1
    else
        echo -e "${GREEN}k3d cluster 'p3' successfully deleted.${NC}"
    fi

    if kubectl get namespace argocd &> /dev/null; then
        echo -e "${RED}Deleting namespace 'argocd'...${NC}"
        kubectl delete namespace argocd
    else
        echo -e "${YELLOW}Namespace 'argocd' does not exist.${NC}"
    fi

    if kubectl get namespace argocd &> /dev/null; then
        echo -e "${RED}Failed to delete namespace 'argocd'.${NC}"
        exit 1
    else
        echo -e "${GREEN}Namespace 'argocd' successfully deleted.${NC}"
    fi

    if kubectl get namespace dev &> /dev/null; then
        echo -e "${RED}Deleting namespace 'dev'...${NC}"
        kubectl delete namespace dev
    else
        echo -e "${YELLOW}Namespace 'dev' does not exist.${NC}"
    fi

    if kubectl get namespace dev &> /dev/null; then
        echo -e "${RED}Failed to delete namespace 'dev'.${NC}"
        exit 1
    else
        echo -e "${GREEN}Namespace 'dev' successfully deleted.${NC}"
    fi
    echo -e "${GREEN}Cleanup script completed successfully.${NC}"

}


main() {
    delete_bonus
    delete_p3
}

main "$@"




