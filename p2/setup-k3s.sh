#!/bin/ash

sudo ip addr replace 192.168.56.110/24 brd 192.168.56.255 dev eth1
ip link set eth1 up
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=192.168.56.110 --flannel-iface=eth1" K3S_TOKEN=4242 sh -
ip route replace 192.168.56.0/24 dev eth1

service k3s restart

# Function to check if the Kubernetes API is ready
wait_for_k8s() {
    echo "Waiting for the Kubernetes API to be ready..."
    while ! kubectl get nodes &> /dev/null; do
        echo "Waiting for API to be ready..."
        sleep 2
    done
    sleep 5
    echo "Kubernetes API is ready."
}

# Function to wait for all pods to be ready
wait_for_pods_ready() {
    echo "Waiting for all pods to be ready..."
    for i in {1..60}; do # Wait up to 120 seconds
        READY_PODS=$(kubectl get pods --all-namespaces -o jsonpath="{.items[*].status.conditions[?(@.type=='Ready')].status}")
        if ! echo $READY_PODS | grep -q "False"; then
            echo "All pods are ready."
            return
        fi
        echo "Waiting for pods to be ready..."
        sleep 2
    done
    echo "Timeout waiting for all pods to be ready. Proceeding anyway..."
}

# Apply YAML files in sequence, waiting for control plane readiness before each
apply_yaml() {
    local yaml_file=$1
    echo "Applying $yaml_file..."
    kubectl apply -f $yaml_file
    echo "$yaml_file applied."
}

wait_for_k8s

# Apply your YAML files in sequence
apply_yaml "/home/vagrant/config/app-one.yml"
apply_yaml "/home/vagrant/config/app-two.yml"
apply_yaml "/home/vagrant/config/app-three.yml"
apply_yaml "/home/vagrant/config/apps-igs.yml"
wait_for_pods_ready