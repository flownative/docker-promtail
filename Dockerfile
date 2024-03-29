FROM grafana/promtail:2.6.1 as promtail
FROM europe-docker.pkg.dev/flownative/docker/base:buster
MAINTAINER Robert Lemke <robert@flownative.com>

# -----------------------------------------------------------------------------
# Promtail
# Latest versions: https://github.com/grafana/loki/releases / https://hub.docker.com/r/grafana/promtail/tags

ENV PROMTAIL_VERSION=2.6.1

ENV FLOWNATIVE_LIB_PATH=/opt/flownative/lib \
    PROMTAIL_BASE_PATH=/opt/flownative/promtail \
    PROMTAIL_CONF_PATH=/opt/flownative/promtail/etc \
    PROMTAIL_TMP_PATH=/opt/flownative/promtail/tmp \
    LOG_DEBUG=false

USER root

COPY root-files /
COPY --from=promtail /usr/bin/promtail /usr/bin/promtail
RUN /build.sh

USER promtail
ENTRYPOINT ["/entrypoint.sh"]
CMD [ "run" ]
