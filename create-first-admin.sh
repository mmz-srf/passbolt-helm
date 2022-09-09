#!/usr/bin/env bash

set -euo pipefail

if [ ! -f variables.env ]
then
  cp variables.env.sample variables.env
fi

. variables.env

kubectl exec -it -c passbolt \
  $(kubectl get po --no-headers -l app.kubernetes.io/name=passbolt-helm | awk '{print $1}') \
  -- su -m -c "bin/cake passbolt register_user \
  -u ${FIRST_ADMIN_EMAIL} \
  -f "${FIRST_ADMIN_NAME}" \
  -l "${FIRST_ADMIN_SURNAME}" -r admin" -s /bin/sh www-data
