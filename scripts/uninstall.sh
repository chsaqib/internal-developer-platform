#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🗑️ Uninstalling Internal Developer Platform...${NC}"

# Confirmation prompt
confirm_uninstall() {
    echo -e "${YELLOW}⚠️  WARNING: This will remove all IDP components and data!${NC}"
    echo -e "${YELLOW}This action cannot be undone.${NC}"
    echo ""
    read -p "Are you sure you want to continue? (Type 'yes' to confirm): " confirmation
    
    if [ "$confirmation" != "yes" ]; then
        echo -e "${BLUE}Uninstall cancelled.${NC}"
        exit 0
    fi
}

# Remove Backstage
remove_backstage() {
    echo -e "${YELLOW}🎭 Removing Backstage...${NC}"
    
    if kubectl get namespace backstage &> /dev/null; then
        kubectl delete namespace backstage --ignore-not-found=true
        echo -e "${GREEN}✅ Backstage removed${NC}"
    else
        echo -e "${YELLOW}⚠️  Backstage namespace not found${NC}"
    fi
}

# Remove Crossplane
remove_crossplane() {
    echo -e "${YELLOW}⚙️ Removing Crossplane...${NC}"
    
    # Remove all managed resources first
    echo "Cleaning up managed resources..."
    kubectl delete managed --all --ignore-not-found=true
    
    # Wait for managed resources to be cleaned up
    echo "Waiting for managed resources cleanup..."
    sleep 30
    
    # Remove Crossplane components
    if kubectl get namespace crossplane-system &> /dev/null; then
        kubectl delete namespace crossplane-system --ignore-not-found=true
        echo -e "${GREEN}✅ Crossplane removed${NC}"
    else
        echo -e "${YELLOW}⚠️  Crossplane namespace not found${NC}"
    fi
}

# Remove Flux
remove_flux() {
    echo -e "${YELLOW}🔄 Removing Flux CD...${NC}"
    
    if command -v flux &> /dev/null; then
        flux uninstall --silent
        echo -e "${GREEN}✅ Flux CD removed${NC}"
    else
        # Manual removal if Flux CLI not available
        if kubectl get namespace flux-system &> /dev/null; then
            kubectl delete namespace flux-system --ignore-not-found=true
            echo -e "${GREEN}✅ Flux CD removed (manual)${NC}"
        else
            echo -e "${YELLOW}⚠️  Flux namespace not found${NC}"
        fi
    fi
}

# Remove monitoring stack
remove_monitoring() {
    echo -e "${YELLOW}📊 Removing monitoring stack...${NC}"
    
    if kubectl get namespace monitoring &> /dev/null; then
        kubectl delete namespace monitoring --ignore-not-found=true
        echo -e "${GREEN}✅ Monitoring stack removed${NC}"
    else
        echo -e "${YELLOW}⚠️  Monitoring namespace not found${NC}"
    fi
}

# Remove CRDs
remove_crds() {
    echo -e "${YELLOW}📋 Removing Custom Resource Definitions...${NC}"
    
    # Remove Crossplane CRDs
    kubectl delete crd --selector=app=crossplane --ignore-not-found=true
    
    # Remove Flux CRDs
    kubectl delete crd --selector=app.kubernetes.io/part-of=flux --ignore-not-found=true
    
    echo -e "${GREEN}✅ CRDs removed${NC}"
}

# Remove persistent volumes (optional)
remove_persistent_data() {
    echo -e "${YELLOW}💾 Checking for persistent data...${NC}"
    
    # List PVs that might be left
    pvs=$(kubectl get pv --no-headers 2>/dev/null | wc -l)
    if [ "$pvs" -gt 0 ]; then
        echo -e "${YELLOW}Found $pvs persistent volumes${NC}"
        read -p "Do you want to remove persistent volumes? (y/N): " remove_pvs
        
        if [ "$remove_pvs" = "y" ] || [ "$remove_pvs" = "Y" ]; then
            kubectl delete pv --all --ignore-not-found=true
            echo -e "${GREEN}✅ Persistent volumes removed${NC}"
        else
            echo -e "${BLUE}ℹ️  Persistent volumes preserved${NC}"
        fi
    else
        echo -e "${BLUE}ℹ️  No persistent volumes found${NC}"
    fi
}

# Clean up any remaining resources
cleanup_remaining() {
    echo -e "${YELLOW}🧹 Cleaning up remaining resources...${NC}"
    
    # Remove any webhook configurations
    kubectl delete mutatingwebhookconfigurations --selector=app=crossplane --ignore-not-found=true
    kubectl delete validatingwebhookconfigurations --selector=app=crossplane --ignore-not-found=true
    
    # Remove any remaining ClusterRoles and ClusterRoleBindings
    kubectl delete clusterroles --selector=app=crossplane --ignore-not-found=true
    kubectl delete clusterrolebindings --selector=app=crossplane --ignore-not-found=true
    
    # Remove Flux webhook configurations
    kubectl delete mutatingwebhookconfigurations --selector=app.kubernetes.io/part-of=flux --ignore-not-found=true
    kubectl delete validatingwebhookconfigurations --selector=app.kubernetes.io/part-of=flux --ignore-not-found=true
    
    echo -e "${GREEN}✅ Cleanup completed${NC}"
}

# Verify removal
verify_removal() {
    echo -e "${YELLOW}🔍 Verifying removal...${NC}"
    
    # Check for remaining namespaces
    remaining_ns=$(kubectl get ns | grep -E "(backstage|crossplane-system|flux-system|monitoring)" | wc -l)
    
    if [ "$remaining_ns" -eq 0 ]; then
        echo -e "${GREEN}✅ All IDP namespaces removed successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Some namespaces may still be terminating${NC}"
        kubectl get ns | grep -E "(backstage|crossplane-system|flux-system|monitoring)" || true
    fi
    
    # Check for remaining CRDs
    remaining_crds=$(kubectl get crd | grep -E "(crossplane|flux)" | wc -l)
    if [ "$remaining_crds" -eq 0 ]; then
        echo -e "${GREEN}✅ All IDP CRDs removed successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Some CRDs may still exist${NC}"
        kubectl get crd | grep -E "(crossplane|flux)" || true
    fi
}

# Main uninstall function
main() {
    echo -e "${BLUE}Starting Internal Developer Platform removal...${NC}\n"
    
    confirm_uninstall
    
    echo -e "\n${BLUE}Proceeding with uninstall...${NC}\n"
    
    # Remove in reverse order of installation
    remove_monitoring
    remove_backstage
    remove_crossplane
    remove_flux
    remove_crds
    remove_persistent_data
    cleanup_remaining
    verify_removal
    
    echo -e "\n${GREEN}🎉 IDP uninstallation completed!${NC}"
    echo -e "\n${BLUE}📋 Post-uninstall notes:${NC}"
    echo "1. Cloud resources may still exist and incur costs"
    echo "2. Git repositories and code remain unchanged"
    echo "3. Some Kubernetes resources may take time to fully terminate"
    echo "4. Check your cloud provider console for any remaining resources"
    
    echo -e "\n${YELLOW}💡 To reinstall the platform, run:${NC}"
    echo "./scripts/install.sh"
}

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

# Run main function
main "$@"