#!/bin/sh


# TProxy mode
if [ "$MODE" == "tproxy" ]; then
  ip rule add fwmark 0x1 lookup 100
  ip route add local default dev lo table 100
  iptables -t mangle -N clash
  iptables -t mangle -A clash -d 0.0.0.0/8 -j RETURN
  iptables -t mangle -A clash -d 10.0.0.0/8 -j RETURN
  iptables -t mangle -A clash -d 127.0.0.0/8 -j RETURN
  iptables -t mangle -A clash -d 169.254.0.0/16 -j RETURN
  iptables -t mangle -A clash -d 172.16.0.0/12 -j RETURN
  iptables -t mangle -A clash -d $LOCAL_IP -j RETURN
  iptables -t mangle -A clash -d 224.0.0.0/4 -j RETURN
  iptables -t mangle -A clash -d 240.0.0.0/4 -j RETURN
  iptables -t mangle -A clash -p udp --dport 53 -j RETURN
  iptables -t mangle -A clash -p tcp -j TPROXY --on-port $TPROXY_PORT --tproxy-mark 0x1
  iptables -t mangle -A clash -p udp -j TPROXY --on-port $TPROXY_PORT --tproxy-mark 0x1
  iptables -t mangle -A PREROUTING -p tcp -j clash
  iptables -t mangle -A PREROUTING -p udp -j clash
  iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE

elif [ "$MODE" == "tun" ]; then
  # Based on https://github.com/Kr328/kr328-clash-setup-scripts/blob/master/setup-clash-tun.sh
  ipset create localnetwork hash:net
  ipset add localnetwork 127.0.0.0/8
  ipset add localnetwork 10.0.0.0/8
  ipset add localnetwork 169.254.0.0/16
  ipset add localnetwork $LOCAL_IP
  ipset add localnetwork 224.0.0.0/4
  ipset add localnetwork 240.0.0.0/4
  ipset add localnetwork 172.16.0.0/12

  ip route replace default dev utun table 0x162

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
  sysctl -w net.ipv4.conf.utun.rp_filter=0
else
  # Bypass private IP address ranges
  iptables -t nat -N CLASH
  iptables -t nat -A CLASH -d 0.0.0.0/8 -j RETURN
  iptables -t nat -A CLASH -d 10.0.0.0/8 -j RETURN
  iptables -t nat -A CLASH -d 127.0.0.0/8 -j RETURN
  iptables -t nat -A CLASH -d 169.254.0.0/16 -j RETURN
  iptables -t nat -A CLASH -d 172.16.0.0/12 -j RETURN
  iptables -t nat -A CLASH -d $LOCAL_IP -j RETURN
  iptables -t nat -A CLASH -d 224.0.0.0/4 -j RETURN
  iptables -t nat -A CLASH -d 240.0.0.0/4 -j RETURN

  # Redirect all TCP traffic to redir port, where Clash listens
  iptables -t nat -A CLASH -p tcp -j REDIRECT --to-ports $REDIR_PORT
  iptables -t nat -A PREROUTING -p tcp -j CLASH
fi



if [ $SS_ON -eq 1 ]; then 
  exec ss-server -c /etc/shadowsocks-libev/config.json > /dev/null &
fi

exec "$@"
