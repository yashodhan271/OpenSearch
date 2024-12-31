# OpenSearch on GKE Autopilot with Operator

This repository contains Terraform configurations to deploy OpenSearch using the OpenSearch K8s Operator on Google Kubernetes Engine (GKE) Autopilot.

## Architecture Overview

- GKE Autopilot Cluster with Workload Identity enabled
- OpenSearch Operator deployment
- OpenSearch cluster managed by the operator
- Network policies for secure communication
- Cost-optimized resource configurations

## Prerequisites

1. Google Cloud Project with billing enabled
2. Terraform >= 1.0
3. `gcloud` CLI configured
4. `kubectl` installed

## Setup Instructions

1. Configure GCP credentials:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="path/to/your/service-account-key.json"
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. Access OpenSearch:
   - Get cluster credentials:
     ```bash
     gcloud container clusters get-credentials [CLUSTER_NAME] --region [REGION] --project [PROJECT_ID]
     ```
   - Port forward the OpenSearch service:
     ```bash
     kubectl port-forward svc/opensearch-cluster-master 9200:9200 -n opensearch
     ```

## Security Considerations

- Workload Identity is enabled for secure pod authentication
- Network policies restrict unauthorized access
- Pod Security Policies are enforced
- Regular automatic node upgrades
- Private GKE cluster with authorized networks

## Cost Optimization

- GKE Autopilot provides automatic scaling
- Resource requests/limits are properly configured
- Spot instances used where applicable
- PVC storage optimized for performance/cost balance

## Validation

1. Check OpenSearch cluster health:
   ```bash
   curl -X GET "localhost:9200/_cluster/health?pretty"
   ```

2. Verify operator status:
   ```bash
   kubectl get opensearchclusters -n opensearch
   ```

## Clean Up

To destroy all resources:
```bash
terraform destroy
```
