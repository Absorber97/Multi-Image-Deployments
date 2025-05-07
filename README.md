# 🚀 Kubernetes Multi-Application Deployment

This repository contains Kubernetes manifests for deploying a suite of microservices and applications to a Kubernetes cluster.

## 📋 Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Directory Structure](#directory-structure)
- [Deployment Instructions](#deployment-instructions)
- [Accessing the Services](#accessing-the-services)
- [Resource Types Explained](#resource-types-explained)
- [Troubleshooting](#troubleshooting)

## 🔍 Overview

The deployment includes the following applications:

| Application | Description | Components |
|-------------|-------------|------------|
| 📝 **Text Summarizer** | Summarizes text inputs | Single service with frontend and API |
| ✅ **Task Management** | Task tracking application | Backend API + Frontend UI |
| 🖥️ **K8s Application** | Demo application | Backend API + Frontend UI |
| 🛒 **Django E-Commerce** | E-commerce platform | Django web application |
| 🗄️ **PostgreSQL** | Relational database | Supporting the Task Management Backend |
| 🤖 **Chatbot Agent** | DaemonSet agent | Runs on every node in the cluster |
| ⏱️ **Batch Jobs** | Maintenance tasks | Cronjobs and one-time jobs |

## 🛠️ Prerequisites

- Kubernetes cluster (GKE or similar)
- `kubectl` command-line tool configured to access your cluster
- `jq` utility installed for JSON processing in deployment commands

## 📁 Directory Structure

```
.
├── README.md                 # This documentation
├── scripts/                  # Helper scripts for deployment and management
│   ├── deploy-all.sh         # Script to deploy all resources in the correct order
│   ├── port-forward.sh       # Script for port-forwarding to services
│   ├── annotate-resources.sh # Script to annotate resources with custom names
│   └── cleanup.sh            # Script to clean up all resources
└── manifests/                # Directory containing Kubernetes manifests
    ├── text-summarizer.yaml  # Text Summarizer deployment and service
    ├── k8s-backend.yaml      # K8s Backend deployment
    ├── k8s-frontend.yaml     # K8s Frontend deployment
    ├── postgres.yaml         # PostgreSQL database
    ├── task-mgt-back.yaml    # Task Management Backend
    ├── task-mgt-front.yaml   # Task Management Frontend
    ├── django-ecommerce.yaml # Django E-Commerce app
    ├── chatbot-daemonset.yaml # Chatbot agent DaemonSet
    ├── daily-cronjob.yaml    # Daily cronjob
    ├── print-job.yaml        # Simple print job
    ├── scheduled-pod.yaml    # Pod scheduled to a specific node
    └── team-ingress.yaml     # Ingress configuration
```

## 🚀 Deployment Instructions

### Using the Deployment Script

For convenience, you can use the provided deployment script to deploy all components in the correct order:

```bash
# Make the script executable
chmod +x scripts/deploy-all.sh

# Run the deployment script
./scripts/deploy-all.sh
```

The script will:
1. Create the namespace
2. Deploy PostgreSQL and wait for it to be ready
3. Deploy backend configurations and services
4. Deploy frontend applications
5. Apply necessary patches
6. Deploy background jobs and agents
7. Finally deploy the ingress

### Manual Quick Start Deployment

```bash
# Create namespace
kubectl create namespace team-apps

# Deploy database first
kubectl apply -f manifests/postgres.yaml

# Wait for PostgreSQL to be ready
kubectl wait --for=condition=Ready pod -l app=postgres -n team-apps --timeout=120s

# Deploy backend configuration
kubectl apply -f manifests/backend-config-updated.yaml

# Deploy application backends
kubectl apply -f manifests/task-mgt-back-updated.yaml
kubectl apply -f manifests/k8s-backend.yaml
kubectl apply -f manifests/backend-service-fix.yaml
kubectl apply -f manifests/backend-service-alias.yaml
kubectl apply -f manifests/text-summarizer.yaml
kubectl apply -f manifests/django-ecommerce.yaml

# Deploy application frontends
kubectl apply -f manifests/task-mgt-front.yaml
kubectl apply -f manifests/k8s-frontend.yaml
kubectl apply -f manifests/frontend-service-fix.yaml

# Apply hostAlias patch to task-mgt-back
kubectl get deploy task-mgt-back -n team-apps -o json | \
  jq '.spec.template.spec.hostAliases = [{"ip": "34.118.232.10", "hostnames": ["localhost"]}]' | \
  kubectl apply -f -

# Deploy background jobs and agents
kubectl apply -f manifests/print-job.yaml
kubectl apply -f manifests/daily-cronjob.yaml
kubectl apply -f manifests/chatbot-daemonset.yaml
kubectl apply -f manifests/scheduled-pod.yaml

# Finally, deploy ingress
kubectl apply -f manifests/team-ingress-fixed.yaml
```

### 📝 Deployment Order Matters!

When deploying the components, follow this order:
1. Database (PostgreSQL) must be deployed first
2. Backend services depend on the database
3. Frontend services depend on backend APIs
4. Ingress should be deployed last after all services are running

## 🌐 Accessing the Services

### Using the Port Forwarding Script

For convenience, you can use the provided port-forwarding script:

```bash
# Make the script executable
chmod +x scripts/port-forward.sh

# Forward all services
./scripts/port-forward.sh all

# Or forward a specific service
./scripts/port-forward.sh frontend
./scripts/port-forward.sh backend
./scripts/port-forward.sh task-front
./scripts/port-forward.sh task-back
./scripts/port-forward.sh text-sum
./scripts/port-forward.sh django
```

### Using Port Forwarding Manually

For local development, you can manually port-forward to each service:

```bash
# Frontend UI
kubectl port-forward -n team-apps svc/k8s-frontend-svc 3000:3000 --address 0.0.0.0

# Backend API
kubectl port-forward -n team-apps svc/k8s-backend-svc 8080:8080 --address 0.0.0.0

# Task Management Frontend
kubectl port-forward -n team-apps svc/task-mgt-front-svc 8081:80 --address 0.0.0.0

# Task Management Backend
kubectl port-forward -n team-apps svc/task-mgt-back-svc 5000:5000 --address 0.0.0.0

# Text Summarizer
kubectl port-forward -n team-apps svc/text-summarizer-svc 8082:80 --address 0.0.0.0

# Django E-commerce
kubectl port-forward -n team-apps svc/django-ecommerce-svc 8000:8000 --address 0.0.0.0
```

The services will be available at:
- 🖥️ Frontend: http://localhost:3000
- 🔄 Backend API: http://localhost:8080
- ✅ Task Management Frontend: http://localhost:8081
- 🔄 Task Management Backend: http://localhost:5000
- 📝 Text Summarizer: http://localhost:8082
- 🛒 Django E-Commerce: http://localhost:8000

### Using Ingress

The applications are exposed through an ingress at the following URLs:
- 🔄 Backend API: http://api.lab.example.com
- 🖥️ Frontend UI: http://ui.lab.example.com

To access these, you'll need to add entries to your `/etc/hosts` file:

```
<INGRESS_IP> api.lab.example.com ui.lab.example.com
```

Where `<INGRESS_IP>` is the external IP of your ingress controller, found with:

```bash
kubectl get ingress -n team-apps
```

### ⭐ Resource Annotation

For better resource management, you can annotate resources with descriptive names using the provided script:

```bash
# Make the script executable
chmod +x scripts/annotate-resources.sh

# Run the annotation script
./scripts/annotate-resources.sh
```

Or manually annotate resources:

```bash
# Annotate pods by app label
kubectl annotate pod -n team-apps -l app=text-summarizer custom-name="Text Summarization Service" --overwrite
kubectl annotate pod -n team-apps -l app=k8s-backend custom-name="Kubernetes Backend API" --overwrite
kubectl annotate pod -n team-apps -l app=k8s-frontend custom-name="Kubernetes Frontend UI" --overwrite
kubectl annotate pod -n team-apps -l app=postgres custom-name="PostgreSQL Database" --overwrite
kubectl annotate pod -n team-apps -l app=task-mgt-back custom-name="Task Management Backend" --overwrite
kubectl annotate pod -n team-apps -l app=task-mgt-front custom-name="Task Management Frontend" --overwrite
kubectl annotate pod -n team-apps -l app=django-ecommerce custom-name="Django E-Commerce App" --overwrite
kubectl annotate pod -n team-apps -l app=chatbot-agent custom-name="Chatbot Agent DaemonSet" --overwrite
```

View the annotated resources:
```bash
kubectl get pods -n team-apps -o custom-columns="NAME:.metadata.name,APP:.metadata.labels.app,CUSTOM-NAME:.metadata.annotations.custom-name"
```

### 🧹 Cleanup

You can use the provided cleanup script to remove all resources:

```bash
# Make the script executable
chmod +x scripts/cleanup.sh

# Run the cleanup script
./scripts/cleanup.sh
```

Or manually clean up resources:

```bash
# Delete ingress first to free up load balancer
kubectl delete ingress -n team-apps --all

# Delete deployments, services, etc.
kubectl delete deployment -n team-apps --all
kubectl delete service -n team-apps --all
kubectl delete configmap -n team-apps --all
kubectl delete job -n team-apps --all
kubectl delete cronjob -n team-apps --all
kubectl delete daemonset -n team-apps --all
kubectl delete pod -n team-apps --all

# Optionally delete the namespace
kubectl delete namespace team-apps
```

## 📚 Resource Types Explained

### 🤖 DaemonSets

The `chatbot-daemonset.yaml` deploys a DaemonSet, which ensures that a copy of a pod runs on each node in the cluster.

![DaemonSet Illustration](https://kubernetes.io/images/docs/components-of-kubernetes.svg)

#### Use Cases:
- 📊 Monitoring agents
- 📝 Log collectors
- 🔄 Node-level services

> 💡 **Key Difference**: Unlike Deployments that control specific replica counts, DaemonSets automatically scale with the number of nodes.

### ⏱️ CronJobs and Jobs

- `daily-cronjob.yaml`: Scheduled job that runs every day at 1 AM
- `print-job.yaml`: One-time job that executes and completes

#### CronJob Schedule Format:
```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of the month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday)
│ │ │ │ │
│ │ │ │ │
* * * * *
```

### 📍 Scheduled Pods

The `scheduled-pod.yaml` demonstrates how to schedule a pod to a specific node using nodeSelector, useful for:
- 🖥️ Hardware-specific workloads
- 💾 Data locality requirements
- 🔐 Security/compliance constraints

## 🔍 Troubleshooting

### 🔌 Port Conflicts

If you see errors about ports already in use when port-forwarding:

```bash
pkill -f "kubectl port-forward"
```

### 🩺 Health Check Issues

If ingress health checks fail:

1. ✅ Verify pods are running:
   ```bash
   kubectl get pods -n team-apps
   ```

2. 📋 Check logs for errors:
   ```bash
   kubectl logs -n team-apps <pod-name>
   ```

3. 🔄 Check service port configurations:
   ```bash
   kubectl get svc -n team-apps
   ```

### 🗄️ Database Connectivity

For Task Management Backend database connection issues:

1. ✅ Verify PostgreSQL is running:
   ```bash
   kubectl get pods -n team-apps -l app=postgres
   ```

2. 📋 Check backend logs:
   ```bash
   kubectl logs -n team-apps -l app=task-mgt-back
   ```

3. 🔄 Verify or reapply the `hostAliases` patch:
   ```bash
   kubectl get deploy task-mgt-back -n team-apps -o json | \
     jq '.spec.template.spec.hostAliases = [{"ip": "34.118.232.10", "hostnames": ["localhost"]}]' | \
     kubectl apply -f -
   ```

