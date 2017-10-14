FROM openjdk:8-alpine

MAINTAINER Adolfo E. García <adolfo.garcia.cr@gmail.com>

ENV EJBCA_VERSION=6_5.0.5 \
    EJBCA_SHA256=85c09d584896bef01d207b874c54ae2f994d38dd85b40fd10c21f71f7210be8a \
    WILDFLY_VERSION=10.1.0.Final \
    WILDFLY_SHA256=1e10c832b715ee7354a94ee57014dfe8ae419c10c536b17a36be030266e02508 \
    DOCKERIZE_VERSION=0.5.0 \
    DOCKERIZE_SHA256=0326b98098bb728259315e5aab35d405875e855c4bf13f66e81bcad22973e419 \
    TINI_VERSION=0.16.1 \
    TINI_SHA256=dc8b1d8c82cf27258d1fbbd2a87715e952796fc291436700dd87b1bc56d0d28f \
    PG_JDBC_VERSION=42.1.4 \
    PG_JDBC_SHA256=4523ed32e9245e762e1df9f0942a147bece06561770a9195db093d9802297735

ENV EJBCA_SRC=https://downloads.sourceforge.net/project/ejbca/ejbca6/ejbca_6_5_0/ejbca_ce_${EJBCA_VERSION}.zip \
    WILDFLY_SRC=https://download.jboss.org/wildfly/${WILDFLY_VERSION}/wildfly-${WILDFLY_VERSION}.zip \
    DOCKERIZE_SRC=https://github.com/jwilder/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-alpine-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz \
    TINI_SRC=https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-muslc-amd64 \
    PG_JDBC_SRC=https://jdbc.postgresql.org/download/postgresql-${PG_JDBC_VERSION}.jar \
    APPSRV_HOME=/opt/wildfly-${WILDFLY_VERSION} \
    EJBCA_HOME=/opt/ejbca_ce_${EJBCA_VERSION} \
    LAUNCH_JBOSS_IN_BACKGROUND=true

COPY conf /tmp/conf
COPY docker-entrypoint.sh /tmp/docker-entrypoint.sh
COPY run-ejbca.sh /tmp/run-ejbca.sh
COPY wildflyconf.cli.sh /tmp/wildflyconf.cli.sh

RUN apk --no-cache upgrade && \
    apk --no-cache add apache-ant && \
    apk --no-cache add --virtual build-deps wget ca-certificates unzip coreutils && \
    wget -P /tmp ${PG_JDBC_SRC} && \
    printf "${PG_JDBC_SHA256} */tmp/postgresql-${PG_JDBC_VERSION}.jar" > /tmp/jdbc.shasum && \
    sha256sum --check --status /tmp/jdbc.shasum && \
    wget -P /tmp ${TINI_SRC} && \
    printf "${TINI_SHA256} */tmp/tini-muslc-amd64" > /tmp/tini.shasum && \
    sha256sum --check --status /tmp/tini.shasum && \
    wget -P /tmp ${DOCKERIZE_SRC} && \
    printf "${DOCKERIZE_SHA256} */tmp/dockerize-alpine-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz" > /tmp/dockerize.shasum && \
    sha256sum --check --status /tmp/dockerize.shasum && \
    wget -P /tmp ${EJBCA_SRC} && \
    printf "${EJBCA_SHA256} */tmp/ejbca_ce_${EJBCA_VERSION}.zip" > /tmp/ejbca.shasum && \
    sha256sum --check --status /tmp/ejbca.shasum && \
    wget -P /tmp ${WILDFLY_SRC} && \
    printf "${WILDFLY_SHA256} */tmp/wildfly-${WILDFLY_VERSION}.zip" > /tmp/wildfly.shasum && \
    sha256sum --check --status /tmp/wildfly.shasum && \
    mkdir -p /opt && \
    tar -C /opt -xvzf /tmp/dockerize-alpine-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz && \
    unzip -d /opt /tmp/ejbca_ce_${EJBCA_VERSION}.zip && \
    unzip -d /opt /tmp/wildfly-${WILDFLY_VERSION}.zip && \
    ash /tmp/wildflyconf.cli.sh && \
    ${APPSRV_HOME}/bin/jboss-cli.sh --file=/tmp/wildflyconf.cli && \
    cp /tmp/conf/* ${EJBCA_HOME}/conf && \
    cp /tmp/docker-entrypoint.sh /opt && \
    cp /tmp/run-ejbca.sh /opt && \
    cp /tmp/tini-muslc-amd64 /opt/tini && \
    chmod u+x /opt/tini && \
    chmod u+x /opt/run-ejbca.sh && \
    chmod u+x /opt/docker-entrypoint.sh && \
    chmod u+x /opt/dockerize && \
    addgroup -S ejbca && \
    adduser -S ejbca -G ejbca && \
    chown -R ejbca:ejbca /opt && \
    apk del build-deps && \
    rm -rf /tmp/* /var/tmp/*

EXPOSE 8442
EXPOSE 8443
EXPOSE 8080

USER ejbca

ENTRYPOINT ["/opt/tini", "-vvv", "--", "tail", "-f", "/opt/docker-entrypoint.sh"]
#ENTRYPOINT ["/opt/tini", "-vvv", "--", "/opt/docker-entrypoint.sh"]
