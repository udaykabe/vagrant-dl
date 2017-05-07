FROM openjdk:8-jre-alpine

# Based on the original by Andrew Grande.  See aperepel/nifi
MAINTAINER Uday Kabe <uday.kabe@exolyte.com>

ENV NIFI_VERSION=1.1.2

RUN wget -q http://www.gtlib.gatech.edu/pub/apache/nifi/$NIFI_VERSION/nifi-$NIFI_VERSION-bin.tar.gz && \
    tar zxf nifi*.tar.gz && \
    rm -f nifi*.tar.gz

VOLUME ["/output", "/flowconf", "/flowrepo",  "/contentrepo", "/databaserepo", "/provenancerepo"]

ENV NIFI_HOME=/nifi-$NIFI_VERSION

#ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk/jre

# web port
EXPOSE 8080

# listen port for web listening processor
EXPOSE 8081

# additional ports for user apps (bind them in a docker-compose.yml 'ports' section)
EXPOSE 10000 10001 10002 10003 10004

WORKDIR $NIFI_HOME/bin

ADD ./entrypoint.sh .
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]

CMD ["./nifi.sh", "run"]
