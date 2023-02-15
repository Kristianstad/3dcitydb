ARG POSTGRES_VERSION="15"
ARG POSTGIS_VERSION="3.3"
ARG THREEDCITYDB_VERSION="4.4.0"

FROM 3dcitydb/3dcitydb-pg:$POSTGRES_VERSION-$POSTGIS_VERSION-$THREEDCITYDB_VERSION

ARG POSTGRES_VERSION

RUN localedef -i sv_SE -c -f UTF-8 -A /usr/share/locale/locale.alias sv_SE.UTF-8 \
 && ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime

ENV LANG=sv_SE.UTF-8 \
    LC_ALL=sv_SE.UTF-8 \
    LC_CTYPE=sv_SE.UTF-8

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        build-essential \
        autoconf \
        automake \
        cmake \
        zlib1g-dev \
        postgresql-server-dev-all \
        libxml2-dev \
        pgagent \
 && git clone https://github.com/verma/laz-perf.git \
 && cd laz-perf \
 && cmake . \
 && make \
 && make install \
 && cd .. \
 && rm -r laz-perf \
 && git clone https://github.com/pgpointcloud/pointcloud \
 && cd pointcloud \
 && ./autogen.sh \
 && ./configure --with-lazperf=/usr/local --with-pgconfig=/usr/lib/postgresql/${POSTGRES_VERSION}/bin/pg_config CFLAGS="-Wall -Werror -O2 -g" \
 && make \
 && make install \
 && apt-get purge -y --auto-remove \
        git \
        ca-certificates \
        build-essential \
        autoconf \
        automake \
        cmake \
        zlib1g-dev \
        postgresql-server-dev-all \
        libxml2-dev \
  && rm -rf /var/lib/apt/lists/* \
  && sed -i '/^docker_create_db_directories().*/a [ -n "$SOCKDIR" ] && mkdir -p -m 775 "$SOCKDIR" || :' /usr/local/bin/docker-entrypoint.sh

COPY ./40_pgpointcloud.sh ./50_pgagent.sh /docker-entrypoint-initdb.d/
