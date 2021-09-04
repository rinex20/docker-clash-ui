# 1. build clash dashboard
FROM node as node_builder
# fix https://github.com/conda-forge/pygridgen-feedstock/issues/10#issuecomment-365914605
RUN apt-get update && apt-get install -y libgl1-mesa-glx
WORKDIR /clash-dashboard-src
RUN git clone https://github.com/Dreamacro/clash-dashboard.git --depth=1 /clash-dashboard-src
RUN npm install
RUN npm run build
RUN mv ./dist /clash_ui

FROM alpine:latest
ENV TZ=Asia/Shanghai

# build shadowsocks-libev
WORKDIR /root
COPY v2ray-plugin.sh /root/v2ray-plugin.sh
COPY xray-plugin.sh /root/xray-plugin.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
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

COPY --from=node_builder /clash_ui /root/.config/clash/ui

VOLUME /etc/shadowsocks-libev

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
