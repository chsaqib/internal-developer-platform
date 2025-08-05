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

1. **Prerequisites**
   - Kubernetes cluster (1.24+)
   - kubectl configured
   - Flux CLI installed
   - GitHub/GitLab access

2. **Installation**
   ```bash
   # Clone this repository
   git clone <your-repo-url>
   cd flux

   # Install the platform
   ./scripts/install.sh
   ```

3. **Access the Platform**
   - Backstage: `http://localhost:3000`
   - Grafana Cloud: Your Grafana Cloud URL

## Directory Structure

```
flux/
├── backstage/              # Backstage configuration and plugins
├── crossplane/             # Crossplane providers and compositions
├── flux-system/            # Flux CD configuration
├── infrastructure/         # Core infrastructure manifests
├── templates/              # Backstage software templates
├── observability/          # Grafana and monitoring setup
├── scripts/                # Installation and utility scripts
└── docs/                   # Documentation
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