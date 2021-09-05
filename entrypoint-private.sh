#!/bin/sh

iptables -t mangle -N CLASH
 iptables -t mangle -F CLASH
 iptables -t mangle -A CLASH -d 0.0.0.0/8 -j RETURN
 iptables -t mangle -A CLASH -d 10.0.0.0/8 -j RETURN
 iptables -t mangle -A CLASH -d 127.0.0.0/8 -j RETURN
 iptables -t mangle -A CLASH -d 169.254.0.0/16 -j RETURN
 iptables -t mangle -A CLASH -d 172.16.0.0/12 -j RETURN
 iptables -t mangle -A CLASH -d 192.168.0.0/16 -j RETURN
 iptables -t mangle -A CLASH -d 224.0.0.0/4 -j RETURN
 iptables -t mangle -A CLASH -d 240.0.0.0/4 -j RETURN
 iptables -t mangle -A CLASH -j MARK --set-xmark 129
# 只设置 PREROUTING
 iptables -t mangle -A PREROUTING -j CLASH

 ip route add default dev utun table 129
 ip rule add fwmark 129 lookup 129
# 
 sysctl -w net.ipv4.conf.utun.rp_filter=0
 sysctl -w net.ipv4.conf.all.rp_filter=0
