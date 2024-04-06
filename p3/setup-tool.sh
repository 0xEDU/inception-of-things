#!/bin/bash

wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash # install k3d
sudo wget -q https://github.com/argoproj/argo-cd/releases/download/v2.10.6/argocd-linux-amd64 -O /usr/local/bin/argocd # install argocd cli
sudo chmod 655 /usr/local/bin/argocd # give proper permission to argocd

k3d cluster create p3-cluster # create cluster

kubectl create namespace argocd # add argocd namespace
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml # install argocd in cluster
kubectl -n argocd patch secret argocd-secret -p '{"stringData":  { "admin.password": "$2y$12$Kg4H0rLL/RVrWUVhj6ykeO3Ei/YqbGaqp.jAtzzUSJdYWT6LUh/n6", "admin.passwordMtime": "'$(date +%FT%T%Z)'" }}' # set argocd password to mysupersecretpassword

kubectl create namespace dev # add dev namespace
