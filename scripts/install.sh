#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE_BACKSTAGE="backstage"
NAMESPACE_CROSSPLANE="crossplane-system"
NAMESPACE_FLUX="flux-system"
NAMESPACE_MONITORING="monitoring"

echo -e "${BLUE}🚀 Installing Internal Developer Platform...${NC}"

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}📋 Checking prerequisites...${NC}"
    
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl is not installed${NC}"
        exit 1
    fi
    
    if ! command -v flux &> /dev/null; then
        echo -e "${RED}❌ Flux CLI is not installed${NC}"
        echo "Please install Flux CLI: https://fluxcd.io/flux/installation/"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        echo -e "${RED}❌ kubectl is not connected to a cluster${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites check passed${NC}"
}

# Create namespaces
create_namespaces() {
    echo -e "${YELLOW}📁 Creating namespaces...${NC}"
    
    kubectl create namespace $NAMESPACE_BACKSTAGE --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace $NAMESPACE_CROSSPLANE --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace $NAMESPACE_MONITORING --dry-run=client -o yaml | kubectl apply -f -
    
    echo -e "${GREEN}✅ Namespaces created${NC}"
}

# Install Flux
install_flux() {
    echo -e "${YELLOW}🔄 Installing Flux CD...${NC}"
    
    # Check if Flux is already installed
    if kubectl get namespace $NAMESPACE_FLUX &> /dev/null; then
        echo -e "${YELLOW}⚠️  Flux is already installed${NC}"
        return
    fi
    
    flux install
    
    # Wait for Flux to be ready
    echo "Waiting for Flux to be ready..."
    kubectl wait --for=condition=ready pod -l app=source-controller -n $NAMESPACE_FLUX --timeout=300s
    kubectl wait --for=condition=ready pod -l app=kustomize-controller -n $NAMESPACE_FLUX --timeout=300s
    
    echo -e "${GREEN}✅ Flux CD installed${NC}"
}

# Install Crossplane
install_crossplane() {
    echo -e "${YELLOW}⚙️ Installing Crossplane...${NC}"
    
    # Install Crossplane using Helm
    if ! kubectl get deployment crossplane -n $NAMESPACE_CROSSPLANE &> /dev/null; then
        kubectl apply -f infrastructure/crossplane/
        
        # Wait for Crossplane to be ready
        echo "Waiting for Crossplane to be ready..."
        kubectl wait --for=condition=ready pod -l app=crossplane -n $NAMESPACE_CROSSPLANE --timeout=300s
    else
        echo -e "${YELLOW}⚠️  Crossplane is already installed${NC}"
    fi
    
    echo -e "${GREEN}✅ Crossplane installed${NC}"
}

# Install Backstage
install_backstage() {
    echo -e "${YELLOW}🎭 Installing Backstage...${NC}"
    
    # Apply Backstage manifests
    kubectl apply -f infrastructure/backstage/
    
    # Wait for Backstage to be ready
    echo "Waiting for Backstage to be ready..."
    kubectl wait --for=condition=ready pod -l app=backstage -n $NAMESPACE_BACKSTAGE --timeout=600s
    
    echo -e "${GREEN}✅ Backstage installed${NC}"
}

# Install monitoring stack
install_monitoring() {
    echo -e "${YELLOW}📊 Installing monitoring stack...${NC}"
    
    # Apply monitoring manifests
    kubectl apply -f observability/
    
    echo -e "${GREEN}✅ Monitoring stack installed${NC}"
}

# Configure GitOps
configure_gitops() {
    echo -e "${YELLOW}🔗 Configuring GitOps...${NC}"
    
    # Apply Flux configurations
    kubectl apply -f flux-system/
    
    echo -e "${GREEN}✅ GitOps configured${NC}"
}

# Display access information
display_access_info() {
    echo -e "\n${GREEN}🎉 Installation completed successfully!${NC}"
    echo -e "\n${BLUE}📋 Access Information:${NC}"
    
    # Get service URLs
    echo -e "\n${YELLOW}Backstage:${NC}"
    kubectl get svc -n $NAMESPACE_BACKSTAGE
    echo "To access Backstage locally:"
    echo "kubectl port-forward svc/backstage 3000:80 -n $NAMESPACE_BACKSTAGE"
    echo "Then open: http://localhost:3000"
    
    echo -e "\n${YELLOW}Grafana Cloud:${NC}"
    echo "Your metrics are being sent to Grafana Cloud"
    echo "Access your dashboards at: \$GRAFANA_CLOUD_URL"
    echo "Note: Configure your Grafana Cloud credentials in the secrets"
    
    echo -e "\n${YELLOW}Crossplane:${NC}"
    echo "Check Crossplane status:"
    echo "kubectl get crossplane -n $NAMESPACE_CROSSPLANE"
    
    echo -e "\n${BLUE}📚 Next Steps:${NC}"
    echo "1. Configure your cloud provider credentials for Crossplane"
    echo "2. Configure your Grafana Cloud credentials in the secrets"
    echo "3. Customize Backstage templates in the templates/ directory"
    echo "4. Set up your Git repository for GitOps workflows"
    echo "5. Read the documentation in docs/ for more details"
}

# Main installation flow
main() {
    echo -e "${BLUE}Starting Internal Developer Platform installation...${NC}\n"
    
    check_prerequisites
    create_namespaces
    install_flux
    install_crossplane
    install_backstage
    install_monitoring
    configure_gitops
    display_access_info
    
    echo -e "\n${GREEN}🚀 IDP installation completed!${NC}"
}

# Run main function
main "$@"