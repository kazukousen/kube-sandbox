
```console
$ kubectl create ns monitoring
```

created monitoring namespace.

```console
$ helm install stable/prometheus --name prometheus --namespace monitoring
```

installed prometheus-tools.

```console
# Switched to context "monitoring".
$ kubectl get deploy prometheus-server -n monitoring -o yaml > prometheus/deployment.yaml
$ kubectl get cm prometheus-server -n monitoring -o yaml > prometheus/configmap.yaml 
```

dumpped prometheus-server yaml.
