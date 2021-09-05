#!/bin/sh

ip tuntap add user root mode tun utun0
ip link set utun0 up

ip route replace default dev utun0 table 0x162
ip rule add fwmark 0x162 lookup 0x162

iptables -t mangle -N CLASH
iptables -t mangle -F CLASH
iptables -t mangle -A CLASH -p tcp --dport 53 -j MARK --set-mark 0x162
iptables -t mangle -A CLASH -p udp --dport 53 -j MARK --set-mark 0x162
iptables -t mangle -A CLASH -m addrtype --dst-type BROADCAST -j RETURN
iptables -t mangle -A CLASH -m set --match-set localnetwork dst -j RETURN
iptables -t mangle -A CLASH -d 198.18.0.0/16 -j MARK --set-mark 0x162
iptables -t mangle -A CLASH -j MARK --set-mark 0x162

iptables -t mangle -I OUTPUT -j CLASH
iptables -t mangle -I PREROUTING -m set ! --match-set localnetwork dst -j MARK --set-mark 0x162

sysctl -w net/ipv4/ip_forward=1
sysctl -w net.ipv4.conf.utun0.rp_filter=0
