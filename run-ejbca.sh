#!/bin/ash
set -e

# Run if installed, otherwise install
if [[ -f "/opt/.ejbca-installed" ]]; then
  rm -rf ${APPSRV_HOME}/standalone/configuration/standalone_xml_history
  $APPSRV_HOME/bin/ejbca.sh
else
  rm -rf ${APPSRV_HOME}/standalone/configuration/standalone_xml_history
  $APPSRV_HOME/bin/standalone.sh &
  cd $EJBCA_HOME
  ant deploy && ant install && touch /opt/.ejbca-installed
fi
