#!/bin/bash

#wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash # install k3d
#sudo wget -q https://github.com/argoproj/argo-cd/releases/download/v2.10.6/argocd-linux-amd64 -O /usr/local/bin/argocd # install argocd cli
#sudo chmod 655 /usr/local/bin/argocd # give proper permission to argocd

#curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

#sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

k3d cluster create p3-cluster -p "8081:8081@loadbalancer" -p "8080:80@loadbalancer" # create cluster

kubectl create namespace argocd # add argocd namespace
kubectl create namespace dev # add dev namespace
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml # install argocd in cluster
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}' # convert ui to loadbalancer
kubectl -n argocd patch secret argocd-secret -p '{"stringData":  { "admin.password": "$2y$12$Kg4H0rLL/RVrWUVhj6ykeO3Ei/YqbGaqp.jAtzzUSJdYWT6LUh/n6", "admin.passwordMtime": "'$(date +%FT%T%Z)'" }}' # set argocd password to mysupersecretpassword
kubectl patch configmap argocd-cm -n argocd -p '{"data":{"timeout.reconciliation": "60s"}}' # update timeout to 60s

./argo-pods-healthcheck.sh

kubectl apply -f argocd-project.yml -n argocd # create project pointing to guribeir repo
kubectl apply -f argocd-application.yml -n argocd # specify repo and application
