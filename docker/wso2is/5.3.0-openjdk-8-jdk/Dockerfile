FROM openjdk:8-jdk

MAINTAINER Uday Kabe uday.kabe@exolyte.com

RUN apt-get update

ENV PRODUCT_NAME identity-server
ENV PRODUCT_ALIAS wso2is
ENV PRODUCT_VERSION 5.3.0

ENV WSO2_HOME /opt/$PRODUCT_ALIAS-$PRODUCT_VERSION
ENV PATH $PATH:$WSO2_HOME/bin

ENV DOWNLOAD_URL http://dist.wso2.org/products/$PRODUCT_NAME/$PRODUCT_VERSION/$PRODUCT_ALIAS-$PRODUCT_VERSION.zip

RUN wget -nv --referer="http://connect.wso2.com/wso2/getform/reg/new_product_download" "$DOWNLOAD_URL" && \
    unzip -q $PRODUCT_ALIAS-$PRODUCT_VERSION.zip -d /opt && \
    rm -f $PRODUCT_ALIAS-$PRODUCT_VERSION.zip

RUN addgroup wso2 && \
    adduser --system --shell /bin/bash --gecos 'WSO2User' --ingroup wso2 --disabled-login wso2user && \
    chown -R wso2user:wso2 $WSO2_HOME

EXPOSE 8000 9763 9443 10500

USER wso2user

RUN echo "log4j.logger.org.wso2.carbon.identity=DEBUG" >> $WSO2_HOME/repository/conf/log4j.properties

CMD ["/bin/bash", "-c", "wso2server.sh", "start"]