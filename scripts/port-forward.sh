#!/bin/bash

# port-forward.sh - Script to port-forward to the various services

# Function to kill any existing port-forwards
kill_forwards() {
  echo "Killing any existing port-forwards..."
  pkill -f "kubectl port-forward" || true
  sleep 2
}

# Check for command line arguments
if [ $# -eq 0 ]; then
  echo "Usage: $0 [service]"
  echo "Available services:"
  echo "  all        - Forward all main services"
  echo "  frontend   - Forward k8s-frontend to localhost:3000"
  echo "  backend    - Forward k8s-backend to localhost:8080"
  echo "  task-front - Forward task-mgt-front to localhost:8081"
  echo "  task-back  - Forward task-mgt-back to localhost:5000"
  echo "  text-sum   - Forward text-summarizer to localhost:80"
  echo "  django     - Forward django-ecommerce to localhost:8000"
  exit 1
fi

# Kill any existing port-forwards
kill_forwards

# Process command line arguments
case "$1" in
  "all")
    echo "Starting port-forwarding for all main services..."
    kubectl port-forward -n team-apps svc/k8s-frontend-svc 3000:3000 --address 0.0.0.0 &
    kubectl port-forward -n team-apps svc/k8s-backend-svc 8080:8080 --address 0.0.0.0 &
    kubectl port-forward -n team-apps svc/task-mgt-front-svc 8081:80 --address 0.0.0.0 &
    kubectl port-forward -n team-apps svc/task-mgt-back-svc 5000:5000 --address 0.0.0.0 &
    kubectl port-forward -n team-apps svc/text-summarizer-svc 8082:80 --address 0.0.0.0 &
    kubectl port-forward -n team-apps svc/django-ecommerce-svc 8000:8000 --address 0.0.0.0 &
    
    echo "Services are accessible at:"
    echo "- Frontend: http://localhost:3000"
    echo "- Backend API: http://localhost:8080"
    echo "- Task Management Frontend: http://localhost:8081"
    echo "- Task Management Backend: http://localhost:5000"
    echo "- Text Summarizer: http://localhost:8082"
    echo "- Django E-commerce: http://localhost:8000"
    ;;
    
  "frontend")
    echo "Starting port-forwarding for k8s-frontend..."
    kubectl port-forward -n team-apps svc/k8s-frontend-svc 3000:3000 --address 0.0.0.0
    ;;
    
  "backend")
    echo "Starting port-forwarding for k8s-backend..."
    kubectl port-forward -n team-apps svc/k8s-backend-svc 8080:8080 --address 0.0.0.0
    ;;
    
  "task-front")
    echo "Starting port-forwarding for task-mgt-front..."
    kubectl port-forward -n team-apps svc/task-mgt-front-svc 8081:80 --address 0.0.0.0
    ;;
    
  "task-back")
    echo "Starting port-forwarding for task-mgt-back..."
    kubectl port-forward -n team-apps svc/task-mgt-back-svc 5000:5000 --address 0.0.0.0
    ;;
    
  "text-sum")
    echo "Starting port-forwarding for text-summarizer..."
    kubectl port-forward -n team-apps svc/text-summarizer-svc 8082:80 --address 0.0.0.0
    ;;
    
  "django")
    echo "Starting port-forwarding for django-ecommerce..."
    kubectl port-forward -n team-apps svc/django-ecommerce-svc 8000:8000 --address 0.0.0.0
    ;;
    
  *)
    echo "Unknown service: $1"
    echo "Available services: all, frontend, backend, task-front, task-back, text-sum, django"
    exit 1
    ;;
esac

echo "Press Ctrl+C to stop port-forwarding." 