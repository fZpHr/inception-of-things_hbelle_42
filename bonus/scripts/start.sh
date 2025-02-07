#!/bin/bash
set -euo pipefail

BLUE='\033[34m'
GREEN='\033[32m'
PURPLE='\033[35m'
YELLOW='\033[33m'
GRAY='\033[90m'
RED='\033[31m'
NC='\033[0m'
TIMEOUT_LONG=3600

log() {
    local level="$1"
    local message="$2"
    local color=""
    case "$level" in
        "INFO")    color=$BLUE ;;
        "SUCCESS") color=$GREEN ;;
        "WARNING") color=$YELLOW ;;
        "ERROR")   color=$RED ;;
        *)         color=$GRAY ;;
    esac
    echo -e "${color}[$level] $message${NC}"
}

check_prerequisites() {
    log "INFO" "Checking prerequisites..."
    local required_commands=("k3d" "kubectl" "jq" "curl" "base64" "timeout")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log "ERROR" "$cmd is not installed"
            exit 1
        fi
    done
    log "SUCCESS" "All prerequisites are met"
}

check_resources() {
    log "INFO" "Checking available resources..."
    local available_space=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "${available_space%.}" -lt 10 ]; then
        log "ERROR" "Insufficient disk space. Need at least 10GB free"
        exit 1
    fi
    local available_mem=$(free -g | awk 'NR==2 {print $7}')
    if [ "$available_mem" -lt 4 ]; then
        log "WARNING" "Low memory available. This might impact performance"
    fi
}

cleanup() {
    log "INFO" "Cleaning up resources..."
    kubectl delete namespace gitlab argocd --grace-period=0 --force 2>/dev/null || true
    docker system prune -f
    docker volume prune -f
    kubectl delete pods --field-selector status.phase=Failed -A 2>/dev/null || true
}

create_k3d_cluster() {
    log "INFO" "Configuring k3d cluster..."
    if k3d cluster list | grep -q "^p3 "; then
        log "WARNING" "Existing 'p3' cluster found. Deleting..."
        k3d cluster delete p3
    fi
    k3d cluster create p3 --api-port 6443 -p 8080:80@loadbalancer
    log "INFO" "Waiting for cluster to be fully ready..."
    for _ in {1..6}; do
        if kubectl cluster-info &>/dev/null; then
            log "SUCCESS" "Cluster is responsive"
            break
        fi
        sleep 5
    done
}

verify_kubernetes_context() {
    log "INFO" "Verifying Kubernetes context..."
    local current_context
    current_context=$(kubectl config current-context)
    if [[ "$current_context" != k3d-p3* ]]; then
        log "WARNING" "Current context is not k3d-p3. Attempting to switch..."
        kubectl config use-context "$(kubectl config get-contexts | grep k3d-p3 | awk '{print $2}')" || {
            log "ERROR" "Failed to switch to k3d-p3 context"
            exit 1
        }
    fi
    log "SUCCESS" "Using k3d-p3 context"
}

install_argocd() {
    log "INFO" "Installing ArgoCD..."
    
    kubectl create namespace argocd 2>/dev/null || true
    
    log "INFO" "Applying ArgoCD manifests..."
    if ! kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml; then
        log "ERROR" "Failed to install ArgoCD"
        exit 1
    fi

    log "INFO" "Applying ArgoCD server configuration..."
    if ! kubectl apply -f ../confs/argocd-server.yaml -n argocd; then
        log "ERROR" "Failed to apply argocd-server.yaml"
        exit 1
    fi

    log "INFO" "Applying ArgoCD application configuration..."
    if ! kubectl apply -f ../confs/argocd.yaml -n argocd; then
        log "ERROR" "Failed to apply argocd.yaml"
        exit 1
    fi
}

wait_for_argocd() {
    log "INFO" "Waiting for ArgoCD to be ready..."
    local start_time=$(date +%s)
    local check_interval=30
    local last_status=""
    
    while true; do
        local current_status=$(kubectl get pods -n argocd -o wide 2>/dev/null || echo "Error getting pod status")
        if [ "$current_status" != "$last_status" ]; then
            log "INFO" "Current ArgoCD pod status:"
            echo "$current_status"
            last_status="$current_status"
        fi
        
        if ! kubectl get pods -n argocd | grep -Ev "Running|Completed|NAME"; then
            log "SUCCESS" "All ArgoCD pods are running or completed"
            break
        fi
        
        if [ $(($(date +%s) - start_time)) -gt "$TIMEOUT_LONG" ]; then
            log "ERROR" "Timeout waiting for ArgoCD pods"
            kubectl get pods -n argocd
            exit 1
        fi
        
        sleep $check_interval
    done
}

install_gitlab() {
    log "INFO" "Installing GitLab..."
    
    kubectl create namespace gitlab 2>/dev/null || true

    if ! kubectl apply -f ../confs/gitlab.yaml -n gitlab; then
        log "ERROR" "Failed to apply gitlab.yaml"
        exit 1
    fi

    if ! kubectl apply -f ../confs/gitlab-server.yaml -n gitlab; then
        log "ERROR" "Failed to apply gitlab-server.yaml"
        exit 1
    fi
}

wait_for_gitlab() {
    log "INFO" "Waiting for GitLab to be ready..."
    local start_time=$(date +%s)
    local check_interval=60
    local last_status=""
    
    while true; do
        local current_status=$(kubectl get pods -n gitlab -o wide 2>/dev/null || echo "Error getting pod status")
        if [ "$current_status" != "$last_status" ]; then
            log "INFO" "Current GitLab pod status:"
            echo "$current_status"
            last_status="$current_status"
        fi
        
        if ! kubectl get pods -n gitlab | grep -Ev "Running|Completed|NAME"; then
            log "SUCCESS" "All GitLab pods are running or completed"
            break
        fi
        
        if [ $(($(date +%s) - start_time)) -gt "$TIMEOUT_LONG" ]; then
            log "ERROR" "Timeout waiting for GitLab pods"
            kubectl get pods -n gitlab
            exit 1
        fi
        
        sleep $check_interval
    done
}

main() {
    log "INFO" "Starting deployment process..."
    set -e
    
    check_prerequisites
    check_resources
    cleanup
    create_k3d_cluster
    verify_kubernetes_context
    
    install_argocd
    wait_for_argocd
    
    install_gitlab
    wait_for_gitlab
    
    log "SUCCESS" "Deployment completed successfully!"
    log "INFO" "ArgoCD Credentials: ${PURPLE}admin / $(kubectl get secret -n argocd argocd-initial-admin-secret -ojsonpath='{.data.password}' | base64 --decode)${NC}"
    log "INFO" "Exec 'kubectl port-forward svc/argocd-server -n argocd 8123:80' to access ArgoCD UI at http://localhost:8123"
    log "INFO" "GitLab Credentials: ${PURPLE}root / $(kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode)${NC}"
    log "INFO" "Exec 'kubectl port-forward svc/gitlab -n gitlab 8321:80' to access GitLab UI at http://localhost:8321"

    kubectl create namespace dev 2>/dev/null || true
}

main "$@"
