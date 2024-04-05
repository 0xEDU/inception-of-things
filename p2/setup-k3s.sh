#!/bin/ash

sudo ip addr replace 192.168.56.110/24 brd 192.168.56.255 dev eth1
ip link set eth1 up
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=192.168.56.110 --flannel-iface=eth1" K3S_TOKEN=4242 sh -
ip route replace 192.168.56.0/24 dev eth1

service k3s restart