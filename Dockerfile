# 1. build clash dashboard
FROM node as node_builder
# fix https://github.com/conda-forge/pygridgen-feedstock/issues/10#issuecomment-365914605
RUN apt-get update && apt-get install -y libgl1-mesa-glx
WORKDIR /clash-dashboard-src
RUN git clone https://github.com/Dreamacro/clash-dashboard.git --depth=1 /clash-dashboard-src
RUN npm install
RUN npm run build
RUN mv ./dist /clash_ui

FROM dreamacro/clash-premium:latest

ENV LOCAL_IP 192.168.0.0/16
ENV MODE tun

WORKDIR /root
COPY entrypoint.sh ./
COPY --from=node_builder /clash_ui /root/.config/clash/ui

RUN apk add --no-cache \
    ca-certificates  \
    bash  \
    curl \
    iptables  \
    ipset \
    bash-doc  \
    bash-completion  \
    rm -rf /var/cache/apk/* && \
    chmod a+x ./entrypoint.sh

ENTRYPOINT ["clash"]
CMD ["./entrypoint.sh"]
