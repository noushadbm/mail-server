#!/bin/bash

# Configuration
DOMAIN="mail.example.com"
DAYS_VALID=365
CERT_DIR="./certs"

echo "=========================================="
echo "Self-Signed Certificate Generator"
echo "=========================================="
echo ""

# Prompt for domain
read -p "Enter your mail server domain (e.g., mail.example.com): " user_domain
if [ ! -z "$user_domain" ]; then
    DOMAIN=$user_domain
fi

echo "Generating certificates for: $DOMAIN"
echo ""

# Create directory for certificates
mkdir -p $CERT_DIR
cd $CERT_DIR

# Generate CA private key
echo "Step 1: Generating CA private key..."
openssl genrsa -out ca-key.pem 4096

# Generate CA certificate
echo "Step 2: Generating CA certificate..."
openssl req -new -x509 -days $DAYS_VALID -key ca-key.pem -out cacert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=Mail-CA"

# Generate server private key
echo "Step 3: Generating server private key..."
openssl genrsa -out ${DOMAIN}-key.pem 4096

# Generate certificate signing request (CSR)
echo "Step 4: Generating certificate signing request..."
openssl req -new -key ${DOMAIN}-key.pem -out ${DOMAIN}.csr \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=${DOMAIN}"

# Create extensions file for SAN (Subject Alternative Name)
cat > ${DOMAIN}.ext << EOF
subjectAltName = DNS:${DOMAIN},DNS:localhost,IP:127.0.0.1
extendedKeyUsage = serverAuth,clientAuth
EOF

# Sign the certificate with CA
echo "Step 5: Signing certificate with CA..."
openssl x509 -req -days $DAYS_VALID -in ${DOMAIN}.csr \
    -CA cacert.pem -CAkey ca-key.pem -CAcreateserial \
    -out ${DOMAIN}-cert.pem -extfile ${DOMAIN}.ext

# Generate DH parameters (this may take a while)
echo "Step 6: Generating DH parameters (this may take several minutes)..."
openssl dhparam -out dh2048.pem 2048

# Cleanup CSR and extension file
rm ${DOMAIN}.csr ${DOMAIN}.ext

echo ""
echo "=========================================="
echo "Certificates generated successfully!"
echo "=========================================="
echo ""
echo "Files created in $CERT_DIR:"
ls -lh
echo ""
echo "Next steps:"
echo "1. Review the certificates"
echo "2. Run './create-k8s-secret.sh' to create Kubernetes secret"
echo ""
