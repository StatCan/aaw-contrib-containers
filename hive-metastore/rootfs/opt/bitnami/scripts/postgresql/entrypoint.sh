#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace

# Load libraries
. /opt/bitnami/scripts/libbitnami.sh
. /opt/bitnami/scripts/libpostgresql.sh

# Load PostgreSQL environment variables
. /opt/bitnami/scripts/postgresql-env.sh

export HADOOP_HOME=/opt/hadoop-3.2.0
export HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.2.0.jar

print_welcome_page

# Enable the nss_wrapper settings
postgresql_enable_nss_wrapper

if [[ "$*" = *"/opt/bitnami/scripts/postgresql/run.sh"* ]]; then
    info "** Starting PostgreSQL setup **"
    /opt/bitnami/scripts/postgresql/setup.sh
    touch "$POSTGRESQL_TMP_DIR"/.initialized
    info "** PostgreSQL setup finished! **"
fi

#This will initialize the DB and start the metastore
/opt/apache-hive-metastore-3.0.0-bin/bin/schematool -initSchema -dbType postgres
/opt/apache-hive-metastore-3.0.0-bin/bin/start-metastore

echo ""
exec "$@"
