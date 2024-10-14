[![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)
[![Maintenance level: Love](https://img.shields.io/badge/maintenance-%E2%99%A1%E2%99%A1%E2%99%A1-ff69b4.svg)](https://www.flownative.com/en/products/open-source.html)
[![Nightly Builds](https://github.com/flownative/docker-promtail/actions/workflows/docker.build.yaml/badge.svg)](https://github.com/flownative/docker-promtail/actions/workflows/docker.build.yaml)

# Flownative Promtail Image

A Docker image
providing [Promtail](https://grafana.com/docs/loki/latest/clients/promtail/)
for [Beach](https://www.flownative.com/beach),
[Local Beach](https://www.flownative.com/localbeach) and other purposes.
Compared to the
official Promtail image, this one provides an opinionated configuration which
can be controlled through environment variables.

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
      - PROMTAIL_LABELS=eyJqb2IiOiAibXktam9iIiwgInNldmVyaXR5IjogImZpbmUifQ==
      - PROMTAIL_LABEL_HOST=localbeach-${BEACH_PROJECT_NAME}
```

## Testing with docker run

Create a directory "test" on your local machine. Within that directory
create a file "test.log".

Then run Promtail with `docker run`:

```bash
docker run -v $(pwd)/logs:/logs \
  -e PROMTAIL_SCRAPE_PATH=/logs/test.log \
  -e PROMTAIL_CLIENT_URL=https://logs-prod-us-central1.grafana.net/loki/api/v1/push \
  -e PROMTAIL_BASIC_AUTH_USERNAME=loki-username \
  -e PROMTAIL_BASIC_AUTH_PASSWORD=loki-password \
  -e PROMTAIL_LABELS=eyJqb2IiOiAibXktam9iIiwgInNldmVyaXR5IjogImZpbmUifQ== \ 
  flownative/promtail
```

In a separate terminal, add test content to the log file, for example with
`echo "some test" >> logs/test.log`.

### Environment variables

| Variable Name                | Type   | Default                                  | Description                                                                                                            |
|------------------------------|--------|------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| PROMTAIL_CLIENT_URL          | string | http://loki_loki_1:3100/loki/api/v1/push | URL pointing to the Loki push endpoint                                                                                 |
| PROMTAIL_LABEL_HOST          | string | $(hostname)                              | Value of the label "host" which is added to all log entries                                                            |
| PROMTAIL_LABELS_BASE64       | string |                                          | Additional labels to set. Must be a BASE64-encoded JSONs string. JSON example: `{"job": "my-job", "severity": "fine"}` |
| PROMTAIL_CLIENT_TENANT_ID    | string |                                          | An optional tenant id to sent as the `X-Scope-OrgID`-header                                                            |
| PROMTAIL_BASIC_AUTH_USERNAME | string |                                          | Username to use for basic auth, if required by Loki                                                                    |
| PROMTAIL_BASIC_AUTH_PASSWORD | string |                                          | Password to use for basic auth, if required by Loki                                                                    |
| PROMTAIL_SCRAPE_PATH         | string | /application/Data/Logs/*.log             | Path leading to log files to be scraped; supports glob syntax                                                          |

## Security aspects

This image is designed to run as a non-root container. When you are running
this image with Docker or in a Kubernetes context, you can take advantage
of the non-root approach by disallowing privilege escalation:

```yaml
$ docker run flownative/promtail:latest --security-opt=no-new-privileges
```
