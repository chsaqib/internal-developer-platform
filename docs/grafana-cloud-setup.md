# Grafana Cloud Setup Guide

This guide explains how to configure the IDP to use Grafana Cloud instead of a local Grafana deployment.

## Prerequisites

1. **Grafana Cloud Account**: Sign up at [grafana.com](https://grafana.com)
2. **Grafana Cloud Instance**: Create or have access to a Grafana Cloud instance
3. **API Key**: Generate a Grafana Cloud API key with appropriate permissions

## Configuration Steps

### 1. Gather Grafana Cloud Information

You'll need the following information from your Grafana Cloud account:

```bash
# Grafana Cloud instance details
GRAFANA_CLOUD_URL="https://your-org.grafana.net"
GRAFANA_CLOUD_API_KEY="your_grafana_cloud_api_key"

# Prometheus remote write details (found in Grafana Cloud portal)
GRAFANA_CLOUD_PROMETHEUS_URL="https://prometheus-prod-01-eu-west-0.grafana.net"
GRAFANA_CLOUD_PROMETHEUS_USERNAME="your_prometheus_username"  
GRAFANA_CLOUD_PROMETHEUS_PASSWORD="your_prometheus_password"
```

### 2. Create Grafana Cloud API Key

1. Log into your Grafana Cloud instance
2. Go to **Configuration** → **API Keys**
3. Click **New API Key**
4. Set the following:
   - **Key name**: `idp-platform`
   - **Role**: `Editor` (or `Admin` if you want to create datasources)
   - **Time to live**: Choose appropriate duration
5. Copy the generated API key

### 3. Get Prometheus Remote Write Credentials

1. In Grafana Cloud portal, go to **My Account**
2. Click on your stack
3. In the **Prometheus** section, note:
   - **Remote Write Endpoint URL**
   - **Username** (usually a numeric ID)
   - **Password/API Key**

### 4. Configure Secrets

#### Method 1: Using kubectl (Recommended)

```bash
# Create the Grafana Cloud configuration secret
kubectl create secret generic grafana-cloud-config \
  --from-literal=url="$(echo -n 'https://your-org.grafana.net' | base64)" \
  --from-literal=api-key="$(echo -n 'your_grafana_cloud_api_key' | base64)" \
  --from-literal=prometheus-url="$(echo -n 'https://prometheus-prod-01-eu-west-0.grafana.net' | base64)" \
  --from-literal=prometheus-username="$(echo -n 'your_prometheus_username' | base64)" \
  --from-literal=prometheus-password="$(echo -n 'your_prometheus_password' | base64)" \
  -n monitoring

# Update Backstage secrets for Grafana Cloud integration
kubectl patch secret backstage-secrets -n backstage --type='merge' -p='{
  "data": {
    "grafana-cloud-url": "'$(echo -n 'https://your-org.grafana.net' | base64)'",
    "grafana-cloud-api-key": "'$(echo -n 'your_grafana_cloud_api_key' | base64)'"
  }
}'
```

#### Method 2: Update .env file

Add to your `.env` file:

```bash
# Grafana Cloud Configuration
GRAFANA_CLOUD_URL=https://your-org.grafana.net
GRAFANA_CLOUD_API_KEY=your_grafana_cloud_api_key
GRAFANA_CLOUD_PROMETHEUS_URL=https://prometheus-prod-01-eu-west-0.grafana.net
GRAFANA_CLOUD_PROMETHEUS_USERNAME=your_prometheus_username
GRAFANA_CLOUD_PROMETHEUS_PASSWORD=your_prometheus_password
```

### 5. Update Prometheus Configuration

Run the configuration updater job:

```bash
kubectl apply -f observability/prometheus-config-update.yaml
```

This will:
1. Update Prometheus configuration with your Grafana Cloud credentials
2. Restart Prometheus to pick up the new configuration
3. Start sending metrics to Grafana Cloud

### 6. Deploy IDP Dashboards to Grafana Cloud

Run the dashboard provisioner:

```bash
kubectl apply -f observability/grafana-config.yaml
```

This creates a job that will:
1. Upload the IDP overview dashboard to your Grafana Cloud instance
2. Configure it with appropriate panels and queries

### 7. Verify Setup

#### Check Prometheus Remote Write

```bash
# Check Prometheus logs for remote write success
kubectl logs deployment/prometheus -n monitoring | grep "remote_write"

# Look for messages like:
# level=info msg="Completed on-disk checkpoint replay" 
# level=info msg="Starting up remote write"
```

#### Check Grafana Cloud

1. Log into your Grafana Cloud instance
2. Go to **Explore** and verify you can see metrics from your cluster
3. Check the "Internal Developer Platform Overview" dashboard

#### Check Backstage Integration

1. Access Backstage at http://localhost:3000
2. Navigate to any component with the Grafana plugin enabled
3. Verify dashboards load from Grafana Cloud

## Troubleshooting

### Prometheus Not Sending Metrics

**Check Configuration:**
```bash
kubectl get configmap prometheus-config -n monitoring -o yaml
```

**Verify Credentials:**
```bash
kubectl get secret grafana-cloud-config -n monitoring -o yaml
```

**Check Prometheus Logs:**
```bash
kubectl logs deployment/prometheus -n monitoring | tail -100
```

### Dashboard Not Appearing in Grafana Cloud

**Check Job Logs:**
```bash
kubectl logs job/grafana-cloud-dashboard-provisioner -n monitoring
```

**Manually Upload Dashboard:**
```bash
# Get the dashboard JSON
kubectl get configmap grafana-cloud-dashboards -n monitoring -o json | jq -r '.data["idp-overview.json"]' > dashboard.json

# Upload via API
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d @dashboard.json \
  "https://your-org.grafana.net/api/dashboards/db"
```

### Backstage Can't Connect to Grafana Cloud

**Check Backstage Logs:**
```bash
kubectl logs deployment/backstage -n backstage | grep grafana
```

**Verify Network Connectivity:**
```bash
kubectl run test-pod --image=curlimages/curl -it --rm -- /bin/sh
# Inside the pod:
curl -H "Authorization: Bearer YOUR_API_KEY" https://your-org.grafana.net/api/health
```

## Cost Optimization

### Reduce Metrics Volume

Edit the Prometheus configuration to scrape less frequently:

```yaml
# In observability/prometheus.yaml
global:
  scrape_interval: 60s  # Increase from 15s to reduce volume
```

### Filter Metrics

Add metric filtering to reduce ingestion costs:

```yaml
# In Prometheus configuration
metric_relabel_configs:
- source_labels: [__name__]
  regex: 'go_.*|process_.*'  # Drop Go runtime metrics
  action: drop
```

## Advanced Configuration

### Custom Datasources

Create additional datasources in Grafana Cloud:

```json
{
  "name": "IDP Prometheus",
  "type": "prometheus", 
  "url": "https://prometheus-prod-01-eu-west-0.grafana.net",
  "access": "proxy",
  "basicAuth": true,
  "basicAuthUser": "your_prometheus_username",
  "secureJsonData": {
    "basicAuthPassword": "your_prometheus_password"
  }
}
```

### Alert Rules

Configure alerting in Grafana Cloud for platform health:

1. Go to **Alerting** → **Alert Rules**
2. Create rules for:
   - Platform component downtime
   - High error rates
   - Resource exhaustion
   - Failed deployments

### Dashboard Folders

Organize dashboards in Grafana Cloud:

1. Create folder: "Internal Developer Platform"
2. Move IDP dashboards to this folder
3. Set appropriate permissions

## Monitoring Costs

### Grafana Cloud Metrics Usage

Monitor your metrics usage in Grafana Cloud:

1. Go to **Billing** → **Usage**
2. Check **Metrics** usage
3. Set up billing alerts if needed

### Optimize Retention

Configure appropriate retention in Grafana Cloud:

1. Go to **Configuration** → **Data Sources**
2. Edit your Prometheus datasource
3. Adjust retention period based on needs

---

With Grafana Cloud properly configured, your IDP will have enterprise-grade monitoring and observability without the operational overhead of managing Grafana infrastructure.