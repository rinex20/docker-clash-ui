
WORKDIR /root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

VOLUME /etc/shadowsocks-libev

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
