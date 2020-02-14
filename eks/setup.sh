#!/bin/sh

eks-setup() {
    eksctl create cluster --name mycluster --version 1.14 --region ap-northeast-1 --managed
    # Metrics Server
    kubectl apply -f $HOME/go/src/github.com/kubernetes-sigs/metrics-server/deploy/kubernetes/
    # Kubernetes Dashboard
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc5/aio/deploy/recommended.yaml
    kubectl create sa eks-admin -n kube-system
    kubectl create clusterrolebinding eks-admin --clusterrole cluster-admin --serviceaccount=kube-system:eks-admin
    # Creating Namespace 'monitoring'
    kubectl create ns monitoring

    eks-prometheus-setup
}

# Prometheus
eks-prometheus-setup() {
    WORK_DIR=$(pwd)
    mkdir -p /tmp/helm && cd /tmp/helm
    helm fetch --untar --untardir . 'stable/prometheus'
    helm template ./prometheus --name prometheus | kubectl apply -f - -n monitoring
    rm -rf /tmp/helm
    cd $WORK_DIR
}

eks-prometheus-cleanup() {
    WORK_DIR=$(pwd)
    mkdir -p /tmp/helm && cd /tmp/helm
    helm fetch --untar --untardir . 'stable/prometheus'
    helm template ./prometheus --name prometheus | kubectl delete -f - -n monitoring
    rm -rf /tmp/helm
    cd $WORK_DIR
}

eks-token() {
    kubectl describe secret $(kubectl get secret -n kube-system | grep eks-admin | awk '{print $1}') -n kube-system | grep token: | awk '{print $2}' 
}

eks-cleanup() {
    eksctl delete cluster --name mycluster --wait
}

eks-prometheus() {
    kubectl port-forward -n monitoring svc/prometheus-server 9090:80
}
