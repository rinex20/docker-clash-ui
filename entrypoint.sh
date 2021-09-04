#!/bin/sh

if [ "$MODE" == "tproxy" ];then
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
  iptables -t mangle -A clash -p tcp -j TPROXY --on-port 7893 --tproxy-mark 0x1
  iptables -t mangle -A clash -p udp -j TPROXY --on-port 7893 --tproxy-mark 0x1
  iptables -t mangle -A PREROUTING -p tcp -j clash
  iptables -t mangle -A PREROUTING -p udp -j clash
  iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
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
  iptables -t nat -A CLASH -p tcp -j REDIRECT --to-ports 7892
  iptables -t nat -A PREROUTING -p tcp -j CLASH
fi

# ss-server -c /etc/shadowsocks-libev/config.json > /dev/null &
exec ss-server -c /etc/shadowsocks-libev/config.json > /dev/null &

exec "$@"
