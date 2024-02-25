## First Login

```
kubectl get pods -n argocd
kubectl exec -it argocd-server-<pod-id> -n argocd -- bash

cat /usr/share/argocd-initial-admin-secret/admin.password

```

