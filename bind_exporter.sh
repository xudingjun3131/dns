#!/bin/bash
cat >> /etc/bind/named.conf.options<< EOF
statistics-channels {
  inet 127.0.0.1 port 53 allow { 127.0.0.1; };
};
EOF
/usr/sbin/named -u bind -g
sleep 10
pid=`ps -ef|grep '/usr/sbin/named' |grep -v grep |awk '{print $2}'`
echo $pid > /data/named.pid
/data/bind_exporter  --bind.pid-file=/data/named.pid  --bind.timeout=20s   --web.listen-address=0.0.0.0:9119   --web.telemetry-path=/metrics   --bind.stats-url=http://localhost:53   --bind.stats-groups=server,view,tasks 2>&1 > /data/dns.log
/etc/init.d/webmin stop
sleep 5
/etc/init.d/webmin start
