#!/bin/bash
export HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.2.0.jar
export PATH=${HIVE_HOME}/bin:${HADOOP_HOME}/bin:$PATH
export JAVA_HOME=/usr/java/openjdk-11

# Check if schema exists / print schema version
if schematool -dbType postgres -info -verbose; then

    # If schema exists validate and upgrade
    schematool -dbType postgres -validate -verbose
    schematool -dbType postgres -upgradeSchema -verbose
else

    # If schema does not exist, create it
    if schematool -dbType postgres -initSchema -verbose; then
        echo "Hive metastore schema created."
    else
        echo "Error creating hive metastore: $?"
    fi
fi

start-metastore
