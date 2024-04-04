#!/bin/ash

if [[ $(hostname) == "guribeirS" ]]; then
	curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=192.168.56.110 --flannel-iface=eth1" K3S_TOKEN=4242 sh -
	k3s="k3s"
else
	curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://192.168.56.110:6443 --token 4242 --flannel-iface=eth1 --node-ip=192.168.56.111" sh -s -
	k3s="k3s-agent"
fi
ip route del default
ip route add default via 192.168.56.1 dev eth1
service $k3s restart
