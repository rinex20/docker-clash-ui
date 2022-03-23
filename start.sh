#!/bin/sh

start_ss-server()
{
  if [ $SS_ON -eq 1 ]; then
    ss-server -c /etc/shadowsocks-libev/config.json >/dev/null 2>&1 &
  fi
}

start_clash(){
  echo "start clash"
  /clash -f /root/config.yaml >/root/clash.log 2>&1 &
  sleep 5
}

create_ipset(){
  ipset create localnetwork hash:net
  ipset add localnetwork 127.0.0.0/8
  ipset add localnetwork 10.0.0.0/8
  ipset add localnetwork 169.254.0.0/16
  ipset add localnetwork 192.168.0.0/16
  ipset add localnetwork 224.0.0.0/4
  ipset add localnetwork 240.0.0.0/4
  ipset add localnetwork 172.16.0.0/12
}

iptables_tproxy(){
  ip rule add fwmark 0x1 lookup 100
  ip route add local default dev lo table 100
  
  iptables -t mangle -N CLASH
  iptables -t mangle -F CLASH
  iptables -t mangle -A CLASH -m addrtype --dst-type BROADCAST -j RETURN
  iptables -t mangle -A CLASH -m set --match-set localnetwork dst -j RETURN
  iptables -t mangle -A CLASH -p udp --dport 53 -j RETURN
  iptables -t mangle -A CLASH -p tcp -j TPROXY --on-port $TPORT --tproxy-mark 0x1
  iptables -t mangle -A CLASH -p udp -j TPROXY --on-port $TPORT --tproxy-mark 0x1
  iptables -t mangle -A PREROUTING -p tcp -j CLASH
  iptables -t mangle -A PREROUTING -p udp -j CLASH
}

iptables_tun(){
  # Based on https://github.com/Kr328/kr328-clash-setup-scripts/blob/master/setup-clash-tun.sh

  ip route replace default dev utun table 0x162
  ip rule add fwmark 0x162 lookup 0x162

  iptables -t mangle -N CLASH
  iptables -t mangle -F CLASH
  iptables -t mangle -A CLASH -p tcp --dport 53 -j MARK --set-xmark 0x162
  iptables -t mangle -A CLASH -p udp --dport 53 -j MARK --set-xmark 0x162
  iptables -t mangle -A CLASH -m addrtype --dst-type BROADCAST -j RETURN
  iptables -t mangle -A CLASH -m set --match-set localnetwork dst -j RETURN
  #iptables -t mangle -A CLASH -d 198.18.0.0/16 -j MARK --set-xmark 0x162
  iptables -t mangle -A CLASH -j MARK --set-xmark 0x162

  iptables -t mangle -A CLASH -j MARK --set-xmark 0x162
  sysctl -w net.ipv4.conf.utun.rp_filter=0
  sysctl -w net.ipv4.conf.all.rp_filter=0 >
}

setup_forward(){
  sysctl -w net/ipv4/ip_forward=1
}  

keep_alive()
{
  # to keep this script live
  tail -f /root/clash.log
}

# main

#start ss server for backHome
start_ss-server

#start clash, then wait 5s to create tun device
start_clash

#create ipset for lan traffic
create_ipset

if [ "$MODE" == "tproxy" ]; then
  iptables_tproxy
else
  iptables_tun
fi

setup_forward

keep_alive

#end

