#!/bin/bash

TOKEN=tokentokentokentoken

# wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash # install k3d
# sudo wget -q https://github.com/argoproj/argo-cd/releases/download/v2.10.6/argocd-linux-amd64 -O /usr/local/bin/argocd # install argocd cli
# sudo chmod 655 /usr/local/bin/argocd # give proper permission to argocd

# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

k3d cluster create bonus-cluster -p "8081:8081@loadbalancer" -p "80:80@loadbalancer" # create cluster

kubectl create namespace gitlab # add dev namespace
kubectl apply -f gitlab.yml -n gitlab # create gitlab deployment


echo "Waiting for gitlab to be ready"
sleep 60
sg docker -c "
	kubectl wait --for=condition=Ready pod -l "app=gitlab" -n gitlab  --timeout=600s
"
sleep 60

echo "Creating gitlab user and token"
sg docker -c "
	kubectl exec $(kubectl get pods -l app=gitlab -n gitlab -o name) -ngitlab -- gitlab-rails runner \"user=User.find_by_username('root'); user.personal_access_tokens.delete_all; user.save!\"
"

sg docker -c "
	kubectl exec $(kubectl get pods -l app=gitlab -n gitlab -o name) -ngitlab -- gitlab-rails runner \"token=User.find_by_username('root').personal_access_tokens.create(scopes: ['write_repository', 'api', 'read_api', 'read_user'], name: 'Automation token', expires_at: 365.days.from_now); token.set_token('${TOKEN}'); token.save!; token;\"
"


cat <<EOF > ~/.config/glab-cli/config.yml
git_protocol: http
api_protocol: http
editor: /usr/bin/vim
check_update: false
display_hyperlinks: false
host: gitlab.127.0.0.1.nip.io
api_host: gitlab.127.0.0.1.nip.io
no_prompt: true
EOF

glab auth login -t ${TOKEN} -h gitlab.127.0.0.1.nip.io

glab auth status

mkdir repo
cd repo
git init
#glab repo create -P root/guribeir-argocd
git remote add origin http://root:${TOKEN}@gitlab.127.0.0.1.nip.io/root/guribeir-argocd.git
git clone https://github.com/Guiribei/guribeir-argocd
cp -r guribeir-argocd/* .
rm -rf guribeir-argocd
git add .
git commit -m "dale"
git push origin master
cd ..

curl --header "PRIVATE-TOKEN: ${TOKEN}" -X PUT http://gitlab.127.0.0.1.nip.io/api/v4/projects/2?visibility=public

kubectl create namespace argocd # add argocd namespace
kubectl create namespace dev # add dev namespace
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml # install argocd in cluster
#kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}' # convert ui to loadbalancer
kubectl -n argocd patch secret argocd-secret -p '{"stringData":  { "admin.password": "$2y$12$Kg4H0rLL/RVrWUVhj6ykeO3Ei/YqbGaqp.jAtzzUSJdYWT6LUh/n6", "admin.passwordMtime": "'$(date +%FT%T%Z)'" }}' # set argocd password to mysupersecretpassword
kubectl patch configmap argocd-cm -n argocd -p '{"data":{"timeout.reconciliation": "60s"}}' # update timeout to 60s

./argo-pods-healthcheck.sh

kubectl apply -f argocd-project.yml -n argocd # create project pointing to guribeir repo
kubectl apply -f argocd-application.yml -n argocd # specify repo and application