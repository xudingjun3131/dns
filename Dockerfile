FROM ubuntu:focal-20200423 AS add-apt-repositories

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg \
 && apt-key adv --fetch-keys http://www.webmin.com/jcameron-key.asc \
 && echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list

FROM ubuntu:focal-20200423

LABEL maintainer="xudingjun3131@163.com"

ENV BIND_USER=bind \
    BIND_VERSION=9.16.1 \
    WEBMIN_VERSION=1.979 \
    DATA_DIR=/data

COPY trusted.gpg /etc/apt/trusted.gpg

COPY sources.list /etc/apt/sources.list

RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      bind9=1:${BIND_VERSION}* bind9-host=1:${BIND_VERSION}* dnsutils \
      webmin=${WEBMIN_VERSION}* \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
COPY bind_exporter.sh  /sbin/bind_exporter.sh
COPY bind_exporter  /data/
COPY named.pid  /data/
RUN chmod 755 /sbin/entrypoint.sh
RUN chmod 755 /sbin/bind_exporter.sh
RUN chmod 755 /data/bind_exporter
RUN chmod 755 /data/named.pid
EXPOSE 53/udp 53/tcp 10000/tcp 9119/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/bin/sh","/sbin/bind_exporter.sh"]
