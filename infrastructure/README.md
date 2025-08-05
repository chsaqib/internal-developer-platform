# Infrastructure Components

This directory contains the essential Kubernetes manifests for your IDP foundation.

## Core Components

### 🎛️ Backstage Directory
- `simple-web-app.yaml` - IDP status dashboard (currently running)
- `postgres.yaml` - PostgreSQL database for applications
- `service.yaml` - Kubernetes service configuration
- `namespace.yaml` - Backstage namespace definition

### ⚙️ Crossplane Directory
- `installation.yaml` - Crossplane core installation (requires Helm)
- `namespace.yaml` - Crossplane system namespace

## What's Running

1. **Simple Web App** - http://localhost:3000 (via port-forward)
2. **PostgreSQL Database** - Ready for applications
3. **Flux CD** - GitOps controllers in flux-system namespace

## Port Forwarding

To access the dashboard:
```bash
kubectl port-forward svc/simple-web-app 3000:80 -n backstage
```

## Next Steps

- Install Helm to enable Crossplane
- Add real Backstage for developer self-service
- Deploy sample applications