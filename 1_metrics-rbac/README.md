
```console
# Switched to context "production".
$ kubectl apply -f prometheus/metrics-reader.yaml
$ kubectl create ns monitoring
$ kubectl create sa metrics-reader -n monitoring
$ kubectl create clusterrolebinding metrics-reader --clusterrole metrics-reader --serviceaccount=monitoring:metrics-reader
```

__In `production` cluster.__  
created metrics-reader RBAC.  

```console
$ kubectl get secret metrics-reader-token-z4fn4 -n monitoring -o jsonpath="{.data.ca\.crt}" | base64 --decode > ca.crt
$ kubectl get secret metrics-reader-token-z4fn4 -n monitoring -o jsonpath="{.data.token}" | base64 --decode > token
```

fetched `metrics-reader`'s `ca.crt` and `token`.

```console
# Switched to context "monitoring".
$ kubectl create secret generic production-metrics-reader --from-file=ca.crt=ca.crt --from-file=token=token -n monitoring
``` 

__In `monitoring` cluster.__  
generated Secret `production-metrics-reader`.  

```console
# change {MASTER_IP} in 1_metrics-rbac/configmap.yaml
$ kubectl apply -f 1_metrics-rbac/deployment.yaml -n monitoring
$ kubectl apply -f 1_metrics-rbac/configmap.yaml -n monitoring
```

editted and applied deployment and configmap.  

```console
$ kubectl port-forward service/prometheus-server 9090:80 -n monitoring &
$ curl -X POST http://localhost:9090/-/reload
```

hot-reload.  



