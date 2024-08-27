BLUE='\033[34m'
GRAY='\033[90m'
RED='\033[31m'
NC='\033[0m'


IP=$(kubectl get node -o wide | awk 'NR==2 {print $6}')
PSSWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
echo -e "${BLUE}Script completed successfully. Access ArgoCD at https://$IP:30080 , password: $PSSWD${NC}"
