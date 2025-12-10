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

### [Note] If value in configmap is changed then deployment will need to be restarted.
```
kubectl apply -f configmap.yaml
kubectl rollout restart deployment mailserver -n dev
```

## Troubleshooting
Checking the service logs
```
kubectl logs -f deployment/mailserver -n dev
```
Checking the service and node IP
```
kubectl get service -n dev
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                                                                                            AGE
mailserver   LoadBalancer   10.43.95.139   192.168.0.170   25:32745/TCP,587:32721/TCP,465:32191/TCP,143:31108/TCP,993:32615/TCP,110:32539/TCP,995:32684/TCP   22h
```

## Testing
```
swaks --to admin@example.com \
      --from sender@example.com \
      --server 10.43.95.139 \
      --port 25 \
      --helo mail.example.com \
      --body "This is a test email from swaks"
```

## Expected Success Output

You should see something like:
```
=== Trying 10.43.95.139:25...
=== Connected to 10.43.95.139.
<-  220 mail.example.com ESMTP
 -> EHLO mail.example.com
<-  250-mail.example.com
 -> MAIL FROM:<sender@example.com>
<-  250 2.1.0 Ok
 -> RCPT TO:<admin@example.com>
<-  250 2.1.5 Ok
 -> DATA
<-  354 End data with <CR><LF>.<CR><LF>
 -> [email content]
 -> .
<-  250 2.0.0 Ok: queued as XXXXXXXXX
 -> QUIT
<-  221 2.0.0 Bye
=== Connection closed with remote host.
```

