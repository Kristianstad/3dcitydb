FROM 3dcitydb/3dcitydb-pg:latest
RUN localedef -i sv_SE -c -f UTF-8 -A /usr/share/locale/locale.alias sv_SE.UTF-8 \
 && ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
ENV LANG sv_SE.UTF-8
