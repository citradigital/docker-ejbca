# /bin/ash
set -e

if [[ -z "${EJBCA_DB_PORT}" ]]; then
	EJBCA_DB_PORT=5432
fi

/opt/dockerize \
	-template ${EJBCA_HOME}/conf/web.properties.tmpl:${EJBCA_HOME}/conf/web.properties \
	-template ${EJBCA_HOME}/conf/database.properties.tmpl:${EJBCA_HOME}/conf/database.properties \
	-template ${EJBCA_HOME}/conf/install.properties.tmpl:${EJBCA_HOME}/conf/install.properties \
	-wait tcp://${EJBCA_DB_HOSTNAME}:${EJBCA_DB_PORT} /opt/run-ejbca.sh
