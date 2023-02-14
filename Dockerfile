FROM 3dcitydb/3dcitydb-pg:15-3.3-4.4.0

ARG POSTGRES_VERSION="15"

RUN localedef -i sv_SE -c -f UTF-8 -A /usr/share/locale/locale.alias sv_SE.UTF-8 \
 && ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime

ENV LANG=sv_SE.UTF-8 \
    LC_ALL=sv_SE.UTF-8 \
    LC_CTYPE=sv_SE.UTF-8

RUN apt-get install -y --no-install-recommends \
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
        libxml2-dev

COPY ./initdb-pgpointcloud.sh /docker-entrypoint-initdb.d/10_pgpointcloud.sh
