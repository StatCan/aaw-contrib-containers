FROM openjdk:11-oraclelinux7
WORKDIR /opt
ENV HADOOP_VERSION=3.3.3
ENV METASTORE_VERSION=3.0.0
ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin

#Hive standalone
RUN curl https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore/${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz \
	| tar xvz -C /opt/ \
	&& ln -s /opt/apache-hive-metastore-${METASTORE_VERSION}-bin /opt/hive-metastore
#Hadoop
RUN curl https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz \
	| tar xvz -C /opt/  \
	&& ln -s /opt/hadoop-$HADOOP_VERSION /opt/hadoop \
	&& rm -r /opt/hadoop/share/doc

# Install azure binaries
RUN curl -L https://repo1.maven.org/maven2/com/microsoft/azure/azure-storage/8.6.6/azure-storage-8.6.6.jar --output /opt/apache-hive-metastore-${METASTORE_VERSION}-bin/lib/azure-storage-8.6.6.jar \
    && curl -L https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-azure/3.3.3/hadoop-azure-3.3.3.jar --output /opt/apache-hive-metastore-${METASTORE_VERSION}-bin/lib/hadoop-azure-3.3.3.jar \
    && curl -L https://repo1.maven.org/maven2/com/microsoft/azure/azure-storage-blob/11.0.1/azure-storage-blob-11.0.1.jar --output /opt/apache-hive-metastore-${METASTORE_VERSION}-bin/lib/azure-storage-blob-11.0.1.jar


# Install the postgresql connector
ENV PG_CONNECTOR_VERSION=42.4.0
RUN curl -L https://jdbc.postgresql.org/download/postgresql-$PG_CONNECTOR_VERSION.jar --output /opt/postgresql-$PG_CONNECTOR_VERSION.jar \
    && ln -s /opt/postgresql-$PG_CONNECTOR_VERSION.jar /opt/hadoop/share/hadoop/common/lib/ \
    && ln -s /opt/postgresql-$PG_CONNECTOR_VERSION.jar /opt/hive-metastore/lib/

COPY entrypoint.sh /entrypoint.sh

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive /entrypoint.sh && chmod +x /entrypoint.sh

USER hive
EXPOSE 9083
ENV PATH="/opt/apache-hive-metastore-${METASTORE_VERSION}-bin/conf:$PATH"

ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]