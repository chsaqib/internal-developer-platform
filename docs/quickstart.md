# Quickstart Guide

Get your Internal Developer Platform up and running in under 30 minutes!

## Prerequisites Checklist

- ✅ Kubernetes cluster (v1.24+)
- ✅ kubectl configured  
- ✅ Flux CLI installed
- ✅ GitHub account with repo creation permissions
- ✅ Cloud provider account (AWS/GCP/Azure)

## 5-Minute Setup

### 1. Clone and Configure

```bash
git clone https://github.com/your-org/idp-platform
cd idp-platform
cp .env.example .env
```

### 2. Edit `.env` with your credentials

```bash
# Minimum required configuration
GITHUB_TOKEN=your_github_token
GITHUB_ORG=your-organization
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
BACKSTAGE_GITHUB_CLIENT_ID=your_oauth_client_id
BACKSTAGE_GITHUB_CLIENT_SECRET=your_oauth_client_secret
```

### 3. Install the Platform

```bash
./scripts/install.sh
```

### 4. Access Your Platform

```bash
# Backstage (Developer Portal)
kubectl port-forward svc/backstage 3000:80 -n backstage

# Check metrics are flowing to Grafana Cloud
kubectl logs deployment/prometheus -n monitoring | grep "remote_write"
```

**URLs:**
- Backstage: http://localhost:3000
- Grafana Cloud: Your Grafana Cloud URL (see setup guide)

## First Steps

### Create Your First Application

1. Open http://localhost:3000
2. Click "Create Component"
3. Select "Application Infrastructure"
4. Fill in details and click "Create"

🎉 **You now have:**
- A GitHub repository
- AWS infrastructure (VPC, S3, RDS)
- Monitoring dashboards
- GitOps workflows

## What's Next?

- 📖 Read the [Developer Guide](developer-guide.md)
- 🏗️ Explore [Templates](../templates/)
- 📊 Configure [Grafana Cloud](grafana-cloud-setup.md)
- 🔧 Customize your [Configuration](../infrastructure/)

## Need Help?

- 📚 [Full Documentation](README.md)
- 🐛 [Troubleshooting](troubleshooting.md)
- 💬 [Community Support](https://github.com/your-org/idp-platform/issues)

## Cleanup

To remove everything:

```bash
./scripts/uninstall.sh
```

---

**Time to productivity: ~15 minutes** ⚡