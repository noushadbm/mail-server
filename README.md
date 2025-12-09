# mail-server

### 1. Create namespace (dev)
```
kubectl apply -f namespace.yaml
```
### 2. Create self signed certificate
This would take several minutes to complete. Can run it with nohup command if want to execute in background.
```
chmod +x generate-cert.sh
./generate-cert.sh
```
OR
```
nohup ./generate-cert.sh &
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
### 7. Add email account
You should add atleast one email account, else pod will crash.
```
kubectl exec -it deployment/mailserver -n dev -- setup email add admin@example.com YourPassword123
```
### 8. Deploy the service
```
kubectl apply -f service.yaml
```


