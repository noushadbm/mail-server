#!/bin/bash

echo "=========================================="
echo "Docker Mailserver Deployment on k3s"
echo "=========================================="
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl not found. Please install kubectl first."
    exit 1
fi

# Create namespace
echo "Step 1: Creating namespace 'dev'..."
kubectl apply -f namespace.yaml
echo ""

# Create persistent volume claims
echo "Step 2: Creating persistent volume claims..."
kubectl apply -f persistent-volumes.yaml
echo ""

# Wait for PVCs to be bound
echo "Waiting for PVCs to be bound..."
kubectl wait --for=jsonpath='{.status.phase}'=Bound pvc/mailserver-data -n dev --timeout=60s
kubectl wait --for=jsonpath='{.status.phase}'=Bound pvc/mailserver-state -n dev --timeout=60s
kubectl wait --for=jsonpath='{.status.phase}'=Bound pvc/mailserver-logs -n dev --timeout=60s
kubectl wait --for=jsonpath='{.status.phase}'=Bound pvc/mailserver-config -n dev --timeout=60s
echo ""

# Create configmap
echo "Step 3: Creating configmap..."
kubectl apply -f configmap.yaml
echo ""

# Create deployment
echo "Step 4: Creating deployment..."
kubectl apply -f deployment.yaml
echo ""

# Create service
echo "Step 5: Creating service..."
kubectl apply -f service.yaml
echo ""

# Wait for deployment to be ready
echo "Waiting for mailserver pod to be ready..."
kubectl wait --for=condition=ready pod -l app=mailserver -n dev --timeout=300s
echo ""

echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Check status with:"
echo "  kubectl get all -n dev"
echo ""
echo "Get service IP with:"
echo "  kubectl get svc mailserver -n dev"
echo ""
echo "View logs with:"
echo "  kubectl logs -f -l app=mailserver -n dev"
echo ""
echo "=========================================="
