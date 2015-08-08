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

exec "$@"
