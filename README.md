[![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)
[![Maintenance level: Love](https://img.shields.io/badge/maintenance-%E2%99%A1%E2%99%A1%E2%99%A1-ff69b4.svg)](https://www.flownative.com/en/products/open-source.html)
[![Nightly Builds](https://github.com/flownative/docker-promtail/actions/workflows/docker.build.yaml/badge.svg)](https://github.com/flownative/docker-promtail/actions/workflows/docker.build.yaml)

# Flownative Promtail Image

A Docker image providing [Promtail](https://grafana.com/docs/loki/latest/clients/promtail/) for [Beach](https://www.flownative.com/beach),
[Local Beach](https://www.flownative.com/localbeach) and other purposes. Compared to the
official Promtail image, this one provides an opinionated configuration which can be
controlled through environment variables.

## Sending logs from Local Beach

```yaml
  addon-promtail:
    image: flownative/promtail
    container_name: ${BEACH_PROJECT_NAME:?Please specify a Beach project name as BEACH_PROJECT_NAME}_addon-promtail
    networks:
      - local_beach
    volumes:
      - ./Data/Logs:/application/Data/Logs:delegated
    environment:
      - PROMTAIL_CLIENT_URL=http://loki_loki_1:3100/loki/api/v1/push
      - PROMTAIL_LABEL_JOB=localbeach-flow
      - PROMTAIL_LABEL_HOST=localbeach-${BEACH_PROJECT_NAME}
```

### Environment variables

| Variable Name                | Type   | Default                                  | Description                                                         |
| ---------------------------- | ------ | ---------------------------------------- | ------------------------------------------------------------------- |
| PROMTAIL_CLIENT_URL          | string | http://loki_loki_1:3100/loki/api/v1/push | URL pointing to the Loki push endpoint                              |
| PROMTAIL_LABEL_HOST          | string | $(hostname)                              | Value of the label "host" which is added to all log entries         |
| PROMTAIL_LABEL_JOB           | string | promtail                                 | Value of the label "job" which is added to all log entries          |
| PROMTAIL_LABEL_ORGANIZATION  | string |                                          | Value of the label "organization" which is added to all log entries |
| PROMTAIL_LABEL_PROJECT       | string |                                          | Value of the label "project" which is added to all log entries      |
| PROMTAIL_CLIENT_TENANT_ID    | string |                                          | An optional tenant id to sent as the `X-Scope-OrgID`-header         |
| PROMTAIL_BASIC_AUTH_USERNAME | string |                                          | Username to use for basic auth, if required by Loki                 |
| PROMTAIL_BASIC_AUTH_PASSWORD | string |                                          | Password to use for basic auth, if required by Loki                 |

## Security aspects

This image is designed to run as a non-root container. When you are running
this image with Docker or in a Kubernetes context, you can take advantage
of the non-root approach by disallowing privilege escalation:

```yaml
$ docker run flownative/promtail:latest --security-opt=no-new-privileges
```
