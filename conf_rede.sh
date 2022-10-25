#!/bin/bash
# This is the network config written by 'subiquity'

read -p "Digite o IP desejado com a máscara, como no exemplo 192.168.0.1/24: " ip
read -p "Digite o gateway desejado, como no exemplo 192.168.0.1: " gateway4
read -p "Digite o(s) dns(s) desejado(s) como no exemplo 192.168.0.1, 192.168.0.2: " dns

echo "$ip, $gateway4, $dns"

echo "# This is the network config written by 'subiquity'
network:
  ethernets:
    eth0:
      dhcp4: false
      addresses: "[$ip]"
      gateway4: "$gateway4"
      nameservers:
              addresses: "[$dns"]
  version: 2" > /etc/netplan/00-installer-config.yaml

netplan apply
ping -c 4 8.8.8.8
