#!/bin/ash

# Reference: https://stackoverflow.com/questions/43408668/datasource-configuration-in-wildfly-10

set -e

FILE=/tmp/wildflyconf.cli

echo "embed-server --std-out=echo --server-config=standalone.xml" > $FILE
echo "batch" >> $FILE
echo "module add --name=org.postgresql --resources=/tmp/postgresql-${PG_JDBC_VERSION}.jar --dependencies=javax.api,javax.transaction.api" >> $FILE
echo '/subsystem=datasources/jdbc-driver=postgres:add(driver-name="org_postgresql_Driver",driver-module-name="org.postgresql",driver-class-name=org.postgresql.Driver)' >> $FILE
echo "run-batch" >> $FILE
