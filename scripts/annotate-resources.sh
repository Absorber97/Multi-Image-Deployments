#!/bin/bash

# annotate-resources.sh - Script to annotate all Kubernetes resources with custom names

echo "🏷️ Annotating all resources with custom names..."

# Annotate pods by app label
echo "Annotating text-summarizer pods..."
kubectl annotate pod -n team-apps -l app=text-summarizer custom-name="Text Summarization Service" --overwrite

echo "Annotating k8s-backend pods..."
kubectl annotate pod -n team-apps -l app=k8s-backend custom-name="Kubernetes Backend API" --overwrite

echo "Annotating k8s-frontend pods..."
kubectl annotate pod -n team-apps -l app=k8s-frontend custom-name="Kubernetes Frontend UI" --overwrite

echo "Annotating postgres pod..."
kubectl annotate pod -n team-apps -l app=postgres custom-name="PostgreSQL Database" --overwrite

echo "Annotating task-mgt-back pods..."
kubectl annotate pod -n team-apps -l app=task-mgt-back custom-name="Task Management Backend" --overwrite

echo "Annotating task-mgt-front pods..."
kubectl annotate pod -n team-apps -l app=task-mgt-front custom-name="Task Management Frontend" --overwrite

echo "Annotating django-ecommerce pods..."
kubectl annotate pod -n team-apps -l app=django-ecommerce custom-name="Django E-Commerce App" --overwrite

echo "Annotating chatbot-agent pods..."
kubectl annotate pod -n team-apps -l app=chatbot-agent custom-name="Chatbot Agent DaemonSet" --overwrite

# Annotate services
echo "Annotating services..."
kubectl annotate service -n team-apps text-summarizer-svc custom-name="Text Summarization Service" --overwrite
kubectl annotate service -n team-apps k8s-backend-svc custom-name="Kubernetes Backend API" --overwrite
kubectl annotate service -n team-apps k8s-frontend-svc custom-name="Kubernetes Frontend UI" --overwrite
kubectl annotate service -n team-apps postgres custom-name="PostgreSQL Database" --overwrite
kubectl annotate service -n team-apps task-mgt-back-svc custom-name="Task Management Backend" --overwrite
kubectl annotate service -n team-apps task-mgt-front-svc custom-name="Task Management Frontend" --overwrite
kubectl annotate service -n team-apps django-ecommerce-svc custom-name="Django E-Commerce App" --overwrite
kubectl annotate service -n team-apps backend-service custom-name="Backend Service Alias" --overwrite

# Annotate deployments
echo "Annotating deployments..."
kubectl annotate deployment -n team-apps text-summarizer custom-name="Text Summarization Service" --overwrite
kubectl annotate deployment -n team-apps k8s-backend custom-name="Kubernetes Backend API" --overwrite
kubectl annotate deployment -n team-apps k8s-frontend custom-name="Kubernetes Frontend UI" --overwrite
kubectl annotate deployment -n team-apps postgres custom-name="PostgreSQL Database" --overwrite
kubectl annotate deployment -n team-apps task-mgt-back custom-name="Task Management Backend" --overwrite
kubectl annotate deployment -n team-apps task-mgt-front custom-name="Task Management Frontend" --overwrite
kubectl annotate deployment -n team-apps django-ecommerce custom-name="Django E-Commerce App" --overwrite

# Annotate other resources
echo "Annotating other resources..."
kubectl annotate daemonset -n team-apps chatbot-agent custom-name="Chatbot Agent DaemonSet" --overwrite
kubectl annotate cronjob -n team-apps daily-heartbeat custom-name="Daily Heartbeat CronJob" --overwrite
kubectl annotate job -n team-apps print-job custom-name="Print Job" --overwrite

echo "Done! Displaying annotated pods:"
kubectl get pods -n team-apps -o custom-columns="NAME:.metadata.name,APP:.metadata.labels.app,CUSTOM-NAME:.metadata.annotations.custom-name" 