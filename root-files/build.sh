#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

useradd --home-dir "${PROMTAIL_BASE_PATH}" --no-create-home --no-user-group --uid 1000 promtail
groupadd --gid 1000 promtail

mkdir -p \
    "${PROMTAIL_BASE_PATH}/etc" \
    "${PROMTAIL_BASE_PATH}/bin" \
    "${PROMTAIL_BASE_PATH}/tmp"

mv /etc/promtail/* "${PROMTAIL_BASE_PATH}/etc/"
mv /usr/bin/promtail "${PROMTAIL_BASE_PATH}/bin/"

chown -R promtail:promtail "${PROMTAIL_BASE_PATH}"
chmod -R g+rwX "${PROMTAIL_BASE_PATH}"
chmod 664 "${PROMTAIL_BASE_PATH}"/etc/*

chmod -R g+rwX "${PROMTAIL_BASE_PATH}"

chown -R promtail:promtail \
    "${PROMTAIL_BASE_PATH}/tmp"

# We don't need logrotate in this image:
rm -f /opt/flownative/supervisor/etc/conf.d/logrotate.conf
