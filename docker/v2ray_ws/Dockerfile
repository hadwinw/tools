# syntax=docker/dockerfile:1
 FROM v2fly/v2fly-core
 COPY config.json /etc/v2ray/config.json
 VOLUME /etc/v2ray
 CMD ["/usr/bin/v2ray", "-config", "/etc/v2ray/config.json"]