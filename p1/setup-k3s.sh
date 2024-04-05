#!/bin/ash

if [[ $(hostname) == "guribeirS" ]]; then
    sudo ip addr replace 192.168.56.110/24 brd 192.168.56.255 dev eth1
    ip link set eth1 up
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=192.168.56.110 --flannel-iface=eth1" K3S_TOKEN=4242 sh -
    k3s="k3s"
    ip route replace 192.168.56.0/24 dev eth1
elif [[ $(hostname) == "guribeirSW" ]]; then
    sudo ip addr replace 192.168.56.111/24 brd 192.168.56.255 dev eth1
    ip link set eth1 up
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://192.168.56.110:6443 --token 4242 --flannel-iface=eth1 --node-ip=192.168.56.111" sh -s -
    k3s="k3s-agent"
    ip route replace 192.168.56.0/24 dev eth1
fi

service $k3s restart