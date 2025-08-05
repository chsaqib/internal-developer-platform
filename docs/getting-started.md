# Getting Started with the Internal Developer Platform

This guide will help you set up and start using the Internal Developer Platform (IDP) built with Backstage, Crossplane, and Flux CD.

## Prerequisites

Before you begin, ensure you have the following:

### Required Tools
- **Kubernetes Cluster** (v1.24 or later)
  - Local: Kind, k3s, Docker Desktop, or Minikube
  - Cloud: EKS, GKE, AKS, or any managed Kubernetes service
- **kubectl** configured to access your cluster
- **Flux CLI** ([Installation Guide](https://fluxcd.io/flux/installation/))
- **Git** for version control
- **Docker** (for building custom images)

### Accounts & Access
- **GitHub/GitLab** account with repository creation permissions
- **Cloud Provider** account (AWS, GCP, or Azure) for infrastructure provisioning
- **Domain/DNS** (optional, for custom domains)

## Quick Installation

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/idp-platform
cd idp-platform
```

### 2. Configure Environment

Copy the example environment file and configure your settings:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```bash
# GitHub Configuration
GITHUB_TOKEN=your_github_token
GITHUB_ORG=your-organization

# Cloud Provider Configuration
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=us-west-2

# Backstage Configuration
BACKSTAGE_GITHUB_CLIENT_ID=your_github_oauth_client_id
BACKSTAGE_GITHUB_CLIENT_SECRET=your_github_oauth_client_secret
```

### 3. Run the Installation Script

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

The installation process will:
1. ✅ Check prerequisites
2. ✅ Create required namespaces
3. ✅ Install Flux CD
4. ✅ Install Crossplane
5. ✅ Deploy Backstage
6. ✅ Set up monitoring (Prometheus & Grafana)
7. ✅ Configure GitOps workflows

### 4. Verify Installation

Check that all components are running:

```bash
# Check Backstage
kubectl get pods -n backstage

# Check Crossplane
kubectl get pods -n crossplane-system

# Check Flux
kubectl get pods -n flux-system

# Check Monitoring
kubectl get pods -n monitoring
```

## Accessing the Platform

### Backstage (Developer Portal)

```bash
# Port forward to access locally
kubectl port-forward svc/backstage 3000:80 -n backstage
```

Then open: http://localhost:3000

**Default Login:** GitHub OAuth (configured during setup)

### Grafana Cloud (Observability)

Your metrics are automatically sent to Grafana Cloud. Access your dashboards at your Grafana Cloud URL.

**Setup Required:**
1. Configure your Grafana Cloud credentials (see [Grafana Cloud Setup Guide](grafana-cloud-setup.md))
2. Dashboards are automatically provisioned to your Grafana Cloud instance

### Prometheus (Metrics)

```bash
# Port forward to access locally (optional)
kubectl port-forward svc/prometheus 9090:9090 -n monitoring
```

Then open: http://localhost:9090

## Configuration

### 1. Set Up Cloud Provider Credentials

#### AWS
```bash
# Create AWS credentials secret
kubectl create secret generic aws-secret \
  --from-literal=creds="[default]
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" \
  -n crossplane-system
```

#### GCP
```bash
# Create GCP service account key
kubectl create secret generic gcp-secret \
  --from-file=creds=path/to/gcp-service-account.json \
  -n crossplane-system
```

### 2. Configure Git Repository for GitOps

Update the GitOps configuration to point to your repository:

```bash
# Edit the GitRepository source
kubectl edit gitrepository flux-system -n flux-system
```

Change the `url` field to your repository:
```yaml
spec:
  url: https://github.com/your-org/your-idp-repo
```

### 3. Update Backstage Configuration

Edit Backstage settings:

```bash
kubectl edit configmap backstage-config -n backstage
```

Key configurations to update:
- GitHub integration settings
- Organization name
- Base URLs
- Catalog locations

## First Steps

### 1. Create Your First Application

1. Open Backstage at http://localhost:3000
2. Click **"Create Component"**
3. Choose **"Application Infrastructure"** template
4. Fill in the details:
   - Name: `my-first-app`
   - Description: `My first application`
   - Environment: `dev`
5. Click **"Create"**

This will:
- Create a GitHub repository
- Provision AWS infrastructure (VPC, S3, etc.)
- Register the application in the catalog

### 2. Deploy a Microservice

1. In Backstage, click **"Create Component"**
2. Choose **"Microservice Application"** template
3. Configure your service:
   - Language: `nodejs`
   - Framework: `express`
   - Environment: `dev`
4. Click **"Create"**

### 3. Provision a Database

1. Click **"Create Component"**
2. Choose **"Database Service"** template
3. Configure the database:
   - Instance class: `db.t3.micro`
   - Storage: `20 GB`
   - Environment: `dev`
4. Click **"Create"**

## Common Tasks

### View Infrastructure Status
- **Crossplane Resources:** `kubectl get managed -A`
- **Flux Deployments:** `kubectl get kustomizations -A`
- **Application Catalog:** Browse in Backstage

### Monitor Platform Health
- **Grafana Cloud Dashboards:** Your Grafana Cloud URL
- **Prometheus Metrics:** Local metrics collection + remote write to Grafana Cloud
- **Backstage Health:** http://localhost:3000/api/app/health

### Troubleshooting
- **Logs:** `kubectl logs -f deployment/backstage -n backstage`
- **Events:** `kubectl get events --sort-by=.metadata.creationTimestamp`
- **Resource Status:** `kubectl describe <resource> <name> -n <namespace>`

## Next Steps

1. **Customize Templates:** Modify templates in the `templates/` directory
2. **Add Providers:** Install additional Crossplane providers
3. **Configure RBAC:** Set up role-based access control
4. **Custom Domains:** Configure ingress for external access
5. **CI/CD Integration:** Connect with your CI/CD pipelines

## Getting Help

- **Documentation:** See the `docs/` directory
- **Issues:** Create an issue in the repository
- **Community:** Join our Slack channel
- **Examples:** Check the `examples/` directory

## Security Considerations

⚠️ **Important Security Notes:**

1. **Change Default Passwords:** Update all default passwords
2. **Use TLS:** Configure TLS certificates for production
3. **Network Policies:** Implement Kubernetes network policies
4. **RBAC:** Configure proper role-based access control
5. **Secrets Management:** Use external secret management solutions
6. **Regular Updates:** Keep all components updated

For detailed security guidelines, see [Security Guide](security.md).