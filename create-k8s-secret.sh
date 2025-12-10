#!/bin/bash

CERT_DIR="./certs"
NAMESPACE="dev"
SECRET_NAME="mailserver-tls"

echo "=========================================="
echo "Creating Kubernetes TLS Secret"
echo "=========================================="
echo ""

# Check if certificate directory exists
if [ ! -d "$CERT_DIR" ]; then
    echo "Error: Certificate directory '$CERT_DIR' not found!"
    echo "Please run './generate-certs.sh' first."
    exit 1
fi

# Find the certificate files
CERT_FILE=$(ls $CERT_DIR/*-cert.pem 2>/dev/null | head -n 1)
KEY_FILE=$(ls $CERT_DIR/*-key.pem 2>/dev/null | head -n 1)
CA_FILE="$CERT_DIR/cacert.pem"
DH_FILE="$CERT_DIR/dh2048.pem"

# Check if all required files exist
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ] || [ ! -f "$CA_FILE" ]; then
    echo "Error: Required certificate files not found!"
    echo "Please run './generate-certs.sh' first."
    exit 1
fi

echo "Using certificates:"
echo "  Certificate: $CERT_FILE"
echo "  Key: $KEY_FILE"
echo "  CA: $CA_FILE"
if [ -f "$DH_FILE" ]; then
    echo "  DH Params: $DH_FILE"
fi
echo ""

# Delete existing secret if it exists
echo "Checking for existing secret..."
if kubectl get secret $SECRET_NAME -n $NAMESPACE &>/dev/null; then
    echo "Deleting existing secret..."
    kubectl delete secret $SECRET_NAME -n $NAMESPACE
fi

# Create the secret
echo "Creating secret '$SECRET_NAME' in namespace '$NAMESPACE'..."

if [ -f "$DH_FILE" ]; then
    kubectl create secret generic $SECRET_NAME \
        --from-file=tls.crt=$CERT_FILE \
        --from-file=tls.key=$KEY_FILE \
        --from-file=ca.crt=$CA_FILE \
        --from-file=dh.pem=$DH_FILE \
        -n $NAMESPACE
else
    kubectl create secret generic $SECRET_NAME \
        --from-file=tls.crt=$CERT_FILE \
        --from-file=tls.key=$KEY_FILE \
        --from-file=ca.crt=$CA_FILE \
        -n $NAMESPACE
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "Secret created successfully!"
    echo "=========================================="
    echo ""
    echo "Verify with:"
    echo "  kubectl describe secret $SECRET_NAME -n $NAMESPACE"
    echo ""
    echo "Next steps:"
    echo "1. Update deployment to use the secret"
    echo "2. Run: kubectl apply -f deployment-with-tls.yaml"
    echo ""
else
    echo ""
    echo "Error: Failed to create secret!"
    exit 1
fi
