#!/bin/bash

# Deploy-all.sh - Script to deploy all Kubernetes resources in the correct order

echo "🚀 Starting deployment of all Kubernetes resources..."
echo

# Create namespace if it doesn't exist
echo "Creating team-apps namespace..."
kubectl create namespace team-apps --dry-run=client -o yaml | kubectl apply -f -

# First deploy database
echo "Deploying PostgreSQL database..."
kubectl apply -f manifests/postgres.yaml

# Wait for database to be ready
echo "Waiting for PostgreSQL to start..."
kubectl wait --for=condition=Ready pod -l app=postgres -n team-apps --timeout=120s

# Deploy configs
echo "Deploying ConfigMaps..."
kubectl apply -f manifests/backend-config-updated.yaml

# Deploy application backends
echo "Deploying application backends..."
kubectl apply -f manifests/task-mgt-back-updated.yaml
kubectl apply -f manifests/k8s-backend.yaml
kubectl apply -f manifests/backend-service-fix.yaml
kubectl apply -f manifests/backend-service-alias.yaml
kubectl apply -f manifests/text-summarizer.yaml
kubectl apply -f manifests/django-ecommerce.yaml

# Deploy application frontends
echo "Deploying application frontends..."
kubectl apply -f manifests/task-mgt-front.yaml
kubectl apply -f manifests/k8s-frontend.yaml
kubectl apply -f manifests/frontend-service-fix.yaml

# Patch services if needed
echo "Applying hostAlias patch to task-mgt-back..."
kubectl get deploy task-mgt-back -n team-apps -o json | jq '.spec.template.spec.hostAliases = [{"ip": "34.118.232.10", "hostnames": ["localhost"]}]' | kubectl apply -f -

# Deploy background jobs and agents
echo "Deploying jobs, cronjobs, and daemon sets..."
kubectl apply -f manifests/print-job.yaml
kubectl apply -f manifests/daily-cronjob.yaml
kubectl apply -f manifests/chatbot-daemonset.yaml
kubectl apply -f manifests/scheduled-pod.yaml

# Deploy ingress last
echo "Deploying ingress..."
kubectl apply -f manifests/team-ingress-fixed.yaml

echo
echo "✅ Deployment complete. Waiting for pods to become ready..."
sleep 5
kubectl get pods -n team-apps

echo
echo "📊 Service endpoints:"
echo "- Backend API: http://api.lab.example.com (External IP: $(kubectl get ingress team-ingress -n team-apps -o jsonpath='{.status.loadBalancer.ingress[0].ip}'))"
echo "- Frontend UI: http://ui.lab.example.com (External IP: $(kubectl get ingress team-ingress -n team-apps -o jsonpath='{.status.loadBalancer.ingress[0].ip}'))"
echo
echo "⚠️ Note: You may need to add these hostnames to your /etc/hosts file or use the port-forward commands from the README." 