#!/bin/bash

# cleanup.sh - Script to clean up all Kubernetes resources

echo "🧹 Cleaning up all Kubernetes resources in namespace 'team-apps'..."
echo
echo "⚠️ This will delete ALL resources in the team-apps namespace!"
echo "Press Ctrl+C within 5 seconds to cancel..."
sleep 5

# Kill any port forwards first
echo "Stopping any port-forwarding processes..."
pkill -f "kubectl port-forward" || true

# Delete ingress first to free up load balancer
echo "Deleting ingress..."
kubectl delete ingress -n team-apps --all

# Delete applications and services
echo "Deleting deployments, services, and other resources..."
kubectl delete deployment -n team-apps --all
kubectl delete service -n team-apps --all
kubectl delete configmap -n team-apps --all
kubectl delete job -n team-apps --all
kubectl delete cronjob -n team-apps --all
kubectl delete daemonset -n team-apps --all
kubectl delete pod -n team-apps --all

# Option to delete the namespace itself
read -p "Do you want to delete the team-apps namespace as well? (y/n): " DELETE_NS
if [[ $DELETE_NS == "y" || $DELETE_NS == "Y" ]]; then
  echo "Deleting namespace 'team-apps'..."
  kubectl delete namespace team-apps
  echo "Namespace deleted."
else
  echo "Namespace 'team-apps' preserved. All resources inside it have been deleted."
fi

echo
echo "✅ Cleanup complete!" 