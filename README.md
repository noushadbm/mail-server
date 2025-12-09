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
### 4. Config map
```
kubectl apply -f configmap.yaml
```
### 5. Deployment
```
kubectl apply -f deployment-with-tls.yaml
```
### 6. Wait for pod to be ready
```
kubectl get pods -n dev -w
```
# 5. Add email account
```
kubectl exec -it deployment/mailserver -n dev -- setup email add admin@example.com YourPassword123
```
