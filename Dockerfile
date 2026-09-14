FROM grafana/promtail:3.6.11 AS promtail
FROM harbor.flownative.io/docker/base:trixie-slim
LABEL org.opencontainers.image.authors="Robert Lemke <robert@flownative.com>"
LABEL org.opencontainers.image.base.name="harbor.flownative.io/docker/base:trixie-slim"

# -----------------------------------------------------------------------------
# Promtail
# Latest versions: https://github.com/grafana/loki/releases / https://hub.docker.com/r/grafana/promtail/tags

ENV PROMTAIL_VERSION=3.6.11

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
