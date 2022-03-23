
FROM dreamacro/clash-premium:latest

ENV TZ=Asia/Shanghai
ENV LOCAL_IP=192.168.0.0/16
ENV MODE=tproxy
ENV SS_ON=0
ENV PAR_0=0
ENV PAR_1=0

WORKDIR /root
COPY start.sh /root/

# build shadowsocks-libev
COPY v2ray-plugin.sh /root/v2ray-plugin.sh
COPY xray-plugin.sh /root/xray-plugin.sh
RUN set -ex \
	&& runDeps="git build-base c-ares-dev autoconf automake libev-dev libtool libsodium-dev linux-headers mbedtls-dev pcre-dev" \
	&& apk add --no-cache --virtual .build-deps ${runDeps} \
	&& mkdir -p /root/libev \
	&& cd /root/libev \
	&& git clone --depth=1 https://github.com/shadowsocks/shadowsocks-libev.git . \
	&& git submodule update --init --recursive \
	&& ./autogen.sh \
	&& ./configure --prefix=/usr --disable-documentation \
	&& make install \
	&& apk add --no-cache \
		tzdata \
		rng-tools \
		ca-certificates \
		$(scanelf --needed --nobanner /usr/bin/ss-* \
		| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
		| xargs -r apk info --installed \
		| sort -u) \
	&& apk del .build-deps \
	&& cd /root \
	&& rm -rf /root/libev \
	&& chmod +x /root/v2ray-plugin.sh /root/xray-plugin.sh \
	&& /root/v2ray-plugin.sh \
	&& /root/xray-plugin.sh \
	&& rm -f /root/v2ray-plugin.sh /root/xray-plugin.sh

# end of build ss

RUN apk add --no-cache \
    ca-certificates  \
    bash  \
    curl \
    iptables  \
    ipset \
    iproute2 \
    bash-doc  \
    tzdata \
    bash-completion  \
    rm -rf /var/cache/apk/* && \
    chmod a+x /root/start.sh && \
    wget -O dashboard.zip https://github.com/haishanh/yacd/archive/gh-pages.zip && \
    unzip dashboard.zip -d /root/.config/clash && \
    mv /root/.config/clash/yacd-gh-pages /root/.config/clash/ui && \
    rm -rf dashboard.zip

CMD ["/root/start.sh"]
