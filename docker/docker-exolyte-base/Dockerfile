FROM ubuntu:16.04

#
# visit https://denibertovic.com/posts/handling-permissions-with-docker-volumes/
# to understand the base structure of this Dockerfile.
#
MAINTAINER Uday Kabe, <uday.kabe@exolyte.com>

ENV GOSU_VERSION 1.9

RUN apt-get update && apt-get -y --no-install-recommends install \
    ca-certificates \
    curl

RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
