FROM docker.io/bitnami/minideb:buster
LABEL maintainer "Bitnami <containers@bitnami.com>"

ENV HOME="/" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux"

ARG EXTRA_LOCALES=""
ARG WITH_ALL_LOCALES="no"

COPY prebuildfs /
# Install required system packages and dependencies
RUN install_packages acl ca-certificates curl gzip libbsd0 libbz2-1.0 libc6 libedit2 libffi6 libgcc1 libgmp10 libgnutls30 libhogweed4 libicu63 libidn2-0 libldap-2.4-2 liblz4-1 liblzma5 libncurses6 libnettle6 libp11-kit0 libpcre3 libreadline7 libsasl2-2 libsqlite3-0 libssl1.1 libstdc++6 libtasn1-6 libtinfo6 libunistring2 libuuid1 libxml2 libxslt1.1 libzstd1 locales procps tar zlib1g
RUN . /opt/bitnami/scripts/libcomponent.sh && component_unpack "gosu" "1.14.0-7" --checksum d6280b6f647a62bf6edc74dc8e526bfff63ddd8067dcb8540843f47203d9ccf1
RUN . /opt/bitnami/scripts/libcomponent.sh && component_unpack "postgresql" "14.3.0-2" --checksum 8e3c3c2328cda6c04a67644d524e9b9ec321bd3dfdd46bfad7ab507eafc6732a
RUN apt-get update && apt-get upgrade -y && \
    rm -r /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitnami
RUN localedef -c -f UTF-8 -i en_US en_US.UTF-8
RUN update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
RUN echo 'en_GB.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

COPY rootfs /
RUN /opt/bitnami/scripts/postgresql/postunpack.sh
RUN /opt/bitnami/scripts/locales/add-extra-locales.sh
ENV APP_VERSION="14.3.0" \
    BITNAMI_APP_NAME="postgresql" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    NSS_WRAPPER_LIB="/opt/bitnami/common/lib/libnss_wrapper.so" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/postgresql/bin:$PATH"

VOLUME [ "/bitnami/postgresql", "/docker-entrypoint-initdb.d", "/docker-entrypoint-preinitdb.d" ]

# Modification to the Bitnami image to include hive-metastore-standalone
ARG HADOOP_VERSION=3.2.0
#Hive standalone
RUN apt-get update && apt-get install -y curl --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*
RUN curl https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz \
	| tar xvz -C /opt/  \
	&& ln -s /opt/hadoop-$HADOOP_VERSION /opt/hadoop \
	&& rm -r /opt/hadoop/share/doc
# Add S3a jars to the classpath using this hack.
RUN ln -s /opt/hadoop/share/hadoop/tools/lib/hadoop-aws* /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/hadoop/share/hadoop/tools/lib/aws-java-sdk* /opt/hadoop/share/hadoop/common/lib/

# Set necessary environment variables.
ENV HADOOP_HOME="/opt/hadoop"
ENV PATH="/opt/spark/bin:/opt/hadoop/bin:${PATH}"

# Download and install the standalone metastore binary.
RUN curl https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore/3.0.0/hive-standalone-metastore-3.0.0-bin.tar.gz \
	| tar xvz -C /opt/ \
	&& ln -s /opt/apache-hive-metastore-3.0.0-bin /opt/hive-metastore

# Install the postgresql connector
ENV PG_CONNECTOR_VERSION=42.3.6
RUN curl -L https://jdbc.postgresql.org/download/postgresql-$PG_CONNECTOR_VERSION.jar --output /opt/postgresql-$PG_CONNECTOR_VERSION.jar \
    && ln -s /opt/postgresql-$PG_CONNECTOR_VERSION.jar /opt/hadoop/share/hadoop/common/lib/ \
    && ln -s /opt/postgresql-$PG_CONNECTOR_VERSION.jar /opt/hive-metastore/lib/ 

EXPOSE 5432

# Install jdk 11 - needed for hadoop and hive
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/
RUN export JAVA_HOME


RUN chmod 755 /opt/bitnami/scripts/postgresql/entrypoint.sh
ENV PATH="/opt/apache-hive-metastore-3.0.0-bin/conf:$PATH"
ENTRYPOINT [ "/opt/bitnami/scripts/postgresql/entrypoint.sh" ]

EXPOSE 9083
CMD [ "/opt/bitnami/scripts/postgresql/run.sh" ]
