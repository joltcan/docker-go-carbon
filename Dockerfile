FROM scratch

LABEL maintainer="Fredrik Lundhag <f@mekk.com>"

EXPOSE 2003 2003/udp 2004 7002 7003 7007 8000 8080

VOLUME ["/var/lib/graphite","/etc/go-carbon", "/var/log/go-carbon"]

ADD passwd.minimal /etc/passwd

ADD go-carbon /

WORKDIR "/var/lib/graphite"

USER carbon

ENTRYPOINT ["/go-carbon"]

CMD ["-config", "/etc/go-carbon/go-carbon.conf", "-pidfile", "/go-carbon.pid"]
