### kubectl deployments

```angular2html
# Create a deployment
kubectl create deployment nginx --image=nginx
# Check the deplolyment
kubectl describe deployment nginx
# Check what events took place to create
kubectl get events
# View output in yaml, useful when creating stuff
kubectl get deployment nginx -o yaml
```