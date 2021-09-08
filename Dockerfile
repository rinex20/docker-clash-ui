FROM rinex20/docker-clash-ui:latest

ENV LOCAL_IP 192.168.0.0/16
ENV MODE tproxy
ENV SS_ON 0

WORKDIR /root
COPY entrypoint.sh ./
COPY run.sh ./

RUN apk add --no-cache \
    ipset \
    rm -rf /var/cache/apk/* && \
    mkdir -p /root/clash && \
    chmod a+x ./run.sh ./entrypoint.sh
    
    
    
    

ENTRYPOINT ["./run.sh"]
CMD ["/usr/local/bin/clash"]
