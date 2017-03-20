FROM scratch

MAINTAINER Fredrik Lundhag <f@mekk.com>

LABEL version="0.9.1"

EXPOSE 2003 2003/udp 2004 7002 7007 8008

VOLUME ["/srv/carbon"]

ADD passwd.minimal /etc/passwd

ADD go-carbon /

WORKDIR "/srv/carbon"

USER go-carbon

ENTRYPOINT ["/go-carbon"]

CMD ["-config", "go-carbon.conf"]
