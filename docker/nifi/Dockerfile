FROM debian:wheezy

MAINTAINER Uday Kabe <uday.kabe@exolyte.com>

ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-8-oracle

# Install Java
RUN     echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list && \
        echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
        echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
        apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
        apt-get update && \
        apt-get install -y --force-yes --no-install-recommends ca-certificates oracle-java8-installer && \
        apt-get clean all && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
        rm -rf /var/cache/oracle-jdk8-installer

RUN apt-get update && \
    apt-get install -y python-software-properties software-properties-common curl

RUN \
    curl -o /etc/apt/sources.list.d/hdf.list -L http://public-repo-1.hortonworks.com/HDF/debian7/2.x/updates/2.0.0.0/hdf.list && \
#    curl -o /etc/apt/sources.list.d/hdf.list -L http://public-repo-1.hortonworks.com/HDF/ubuntu12/2.x/updates/2.0.0.0/hdf.list && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xB9733A7A07513CAD && \
    apt-get update && \
    apt-get install -y nifi

EXPOSE 8080 8081

ENV TZ=America/Chicago

CMD ["/usr/hdf/current/nifi/bin/nifi.sh", "run"]
