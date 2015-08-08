#!/bin/bash -x
#
# A helper script for ENTRYPOINT.

set -e

if [ -n "${GCLOUD_ACCOUNT}" ]; then
  echo ${GCLOUD_ACCOUNT} >> /opt/gcloud/auth.base64
  base64 -d /opt/gcloud/auth.base64 >> /opt/gcloud/auth.json
  gcloud auth activate-service-account --key-file=/opt/gcloud/auth.json
fi

if [ -n "${GCLOUD_ACCOUNT_FILE}" ]; then
  gcloud auth activate-service-account --key-file=${GCLOUD_ACCOUNT_FILE}
fi

if [ -n "${GCLOUD_CRON}" ]; then
  echo ${GCLOUD_CRON} >> /opt/gcloud/cron.base64
  base64 -d /opt/gcloud/cron.base64 >> /opt/gcloud/cron.txt
  crontab <<< cat /opt/gcloud/cron.txt
  crontab -l
fi

if [ -n "${GCLOUD_CRONFILE}" ]; then
  crontab <<< cat ${GCLOUD_CRONFILE}
  crontab -l
fi

if [ "$1" = 'supervisord' ]; then
  exec /usr/bin/supervisord -n -c /etc/supervisord.conf
fi

exec "$@"
