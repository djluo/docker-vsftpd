# vim:set et ts=2 sw=2 syntax=dockerfile:

FROM       docker.xlands-inc.com/baoyu/debian
MAINTAINER djluo <dj.luo@baoyugame.com>

RUN export http_proxy="http://172.17.42.1:8080/" \
    && export DEBIAN_FRONTEND=noninteractive     \
    && apt-get update \
    && apt-get install -y vsftpd db-util \
    && apt-get clean \
    && unset http_proxy DEBIAN_FRONTEND \
    && rm -rf usr/share/locale \
    && rm -rf usr/share/man    \
    && rm -rf usr/share/doc    \
    && rm -rf usr/share/info   \
    && find var/lib/apt -type f -exec rm -fv {} \;

COPY ./entrypoint.pl     /entrypoint.pl
COPY ./conf/vsftpd.conf  /etc/vsftpd.conf
COPY ./conf/vsftpd.pam   /etc/pam.d/vsftpd-pam
COPY ./bin/add-user      /usr/bin/add-user
COPY ./bin/del-user      /usr/bin/del-user

VOLUME     ["/etc/vsftpd/", "/data/", "/logs/"]
ENTRYPOINT ["/entrypoint.pl"]
CMD        ["/usr/sbin/vsftpd"]
