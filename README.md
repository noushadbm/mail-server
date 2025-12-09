# mail-server

### 1. Create namespace (dev)
```
kubectl apply -f namespace.yaml
```
### 2. Create self signed certificate
```
chmod +x generate-cert.sh
./generate-cert.sh
```
### 3. Create k8s secret
```
chmod +x create-k8s-secret.sh
./create-k8s-secret.sh
```
### 4.
