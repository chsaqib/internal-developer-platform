# Internal Developer Platform with Backstage, Crossplane, and Flux CD

This repository contains a complete Internal Developer Platform (IDP) implementation that combines:

- **Backstage** - Developer portal and UI for self-service capabilities
- **Crossplane** - Infrastructure as Code using Kubernetes CRDs 
- **Flux CD** - GitOps continuous delivery
- **Grafana Cloud** - Observability and monitoring (SaaS)

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Developers    │───▶│   Backstage     │───▶│   Git Repos     │
│                 │    │   (UI/Portal)   │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                ▼                        ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   Templates     │    │   Flux CD       │
                       │   & Workflows   │    │   (GitOps)      │
                       └─────────────────┘    └─────────────────┘
                                                         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Grafana      │◀───│   Kubernetes    │◀───│   Crossplane    │
│  (Observability)│    │    Cluster      │    │     (IaC)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Key Benefits

- **Developer Self-Service**: Developers can provision infrastructure and deploy applications through intuitive UI
- **Standardized Workflows**: Consistent deployment patterns and best practices
- **GitOps Automation**: All changes tracked in Git with automated deployments
- **Infrastructure as Code**: Declarative infrastructure management
- **Comprehensive Observability**: Full visibility into applications and infrastructure

## Quick Start

### Prerequisites ✅
- Kubernetes cluster (Docker Desktop) ✅
- kubectl configured ✅
- Flux CLI installed ✅
- GitHub repository ✅

### Current Status ✅
Your IDP foundation is **OPERATIONAL**!

```bash
# Access the platform dashboard
kubectl port-forward svc/simple-web-app 3000:80 -n backstage
# Open: http://localhost:3000
```

### What's Running
- **Platform Dashboard**: Real-time status monitoring
- **Flux CD**: GitOps continuous delivery
- **PostgreSQL**: Database infrastructure
- **Kubernetes**: Container orchestration

## Directory Structure

```
idp/
├── infrastructure/         # Core infrastructure manifests
│   ├── backstage/         # Web dashboard and PostgreSQL
│   └── crossplane/        # Infrastructure as Code (future)
├── flux-system/           # Flux CD GitOps configuration
├── observability/         # Monitoring setup (future)
├── templates/             # Application templates (future)
├── scripts/               # Installation scripts
└── docs/                  # Documentation
```

## Getting Started

See the [Getting Started Guide](docs/getting-started.md) for detailed setup instructions.

## Documentation

- [Architecture Overview](docs/architecture.md)
- [Developer Guide](docs/developer-guide.md)
- [Platform Engineer Guide](docs/platform-engineer-guide.md)
- [Templates Guide](docs/templates.md)
- [Troubleshooting](docs/troubleshooting.md)

## Contributing

Please read our [Contributing Guide](docs/contributing.md) for details on our code of conduct and development process.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.