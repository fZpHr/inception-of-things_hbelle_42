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
    
    install_gitlab
    wait_for_gitlab
    
    while [[ $(kubectl get pods -n gitlab -l app=gitlab -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
        sleep 5
    done
    POD=$(kubectl get pods -n gitlab -l app=gitlab -o jsonpath="{.items[0].metadata.name}")

    kubectl exec -it $POD -n gitlab -- gitlab-rails runner "
    user = User.find_by(username: 'root')
    user.password = 'new_password'
    user.password_confirmation = 'new_password'
    user.save!
    "
    kubectl delete application wil42-playground -n argocd
    log "SUCCESS" "Deployment completed successfully!"
    IP_ARGO=$(kubectl get node -o wide | awk 'NR==2 {print $6}')
    log "INFO" "to access GitLab UI at http://$IP_ARGO:30081"

    # sudo kubectl get pods -n gitlab -o wide
    # kubectl apply -f ../confs/argocd.yaml
    # sudo kubectl apply -f ../confs/gitlab-secret.yaml
}

main "$@"
