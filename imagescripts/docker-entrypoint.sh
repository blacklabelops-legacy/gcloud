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

log_command=""

if [ -n "${LOG_FILE}" ]; then
  log_command=" 2>&1 | tee -a "${LOG_FILE}
fi

if [ -n "${DELAYED_START}" ]; then
  exec sleep ${DELAYED_START}
fi

if [ "$1" = 'cron' ]; then
  croncommand="crond -n -x sch"${log_command}
  bash -c "${croncommand}"
fi

exec "$@"
