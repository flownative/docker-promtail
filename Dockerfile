FROM grafana/promtail:2.4.2 as promtail
FROM europe-docker.pkg.dev/flownative/docker/base:buster
MAINTAINER Robert Lemke <robert@flownative.com>

# -----------------------------------------------------------------------------
# Promtail
# Latest versions: https://github.com/grafana/loki/releases

ENV PROMTAIL_VERSION=2.4.2

ENV FLOWNATIVE_LIB_PATH=/opt/flownative/lib \
    PROMTAIL_BASE_PATH=/opt/flownative/promtail \
    LOG_DEBUG=false

USER root

COPY root-files /
COPY --from=promtail /usr/bin/promtail /usr/bin/promtail
COPY --from=promtail /etc/promtail /etc/promtail
RUN /build.sh

USER promtail
ENTRYPOINT ["/entrypoint.sh"]
CMD [ "run" ]
