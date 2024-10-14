#!/bin/bash
# shellcheck disable=SC1090

# =======================================================================================
# LIBRARY: PROMTAIL
# =======================================================================================

# Load helper lib

. "${FLOWNATIVE_LIB_PATH}/log.sh"
. "${FLOWNATIVE_LIB_PATH}/files.sh"
. "${FLOWNATIVE_LIB_PATH}/validation.sh"
. "${FLOWNATIVE_LIB_PATH}/process.sh"

# ---------------------------------------------------------------------------------------
# promtail_env() - Load global environment variables for configuring Promtail
#
# @global PROMTAIL_* The PROMTAIL_ environment variables
# @return "export" statements which can be passed to eval()
#
promtail_env() {
    cat <<"EOF"
export PROMTAIL_BASE_PATH="${PROMTAIL_BASE_PATH}"
export PROMTAIL_CONF_PATH="${PROMTAIL_BASE_PATH}/etc"
export PROMTAIL_TMP_PATH="${PROMTAIL_BASE_PATH}/tmp"
export PROMTAIL_CLIENT_URL="${PROMTAIL_CLIENT_URL:-http://loki:3100/loki/api/v1/push}"
export PROMTAIL_CLIENT_TENANT_ID="${PROMTAIL_CLIENT_TENANT_ID:-}"
export PROMTAIL_BASIC_AUTH_USERNAME="${PROMTAIL_BASIC_AUTH_USERNAME:-}"
export PROMTAIL_BASIC_AUTH_PASSWORD="${PROMTAIL_BASIC_AUTH_PASSWORD:-}"
export PROMTAIL_SCRAPE_PATH=${PROMTAIL_SCRAPE_PATH:-/application/Data/Logs/*.log}
export PROMTAIL_LABELS_BASE64=${PROMTAIL_LABELS_BASE64:-}
export PROMTAIL_LABELS=${PROMTAIL_LABELS:-}
export PROMTAIL_LABEL_HOST=${PROMTAIL_LABEL_HOST:-$(hostname)}
export PATH="${PATH}:${PROMTAIL_BASE_PATH}/bin"
EOF
}

# ---------------------------------------------------------------------------------------
# promtail_render_config() - Render the configuration file for Promtail
#
# @global PROMTAIL_* The PROMTAIL_ environment variables
#
promtail_render_config() {
    default_labels='{ "job": "promtail" }'

    if [ -n "$PROMTAIL_LABELS_BASE64" ]; then
      decoded_labels=$(echo "$PROMTAIL_LABELS_BASE64" | base64 --decode)
    else
      decoded_labels="$default_labels"
    fi

    # Convert JSON to YAML format for labels and add proper indentation
    labels_yaml=$(echo "$decoded_labels" | jq -r 'to_entries | map("          \(.key): \(.value|@sh)") | .[]')

    # Replace placeholders in the template configuration file using awk
    awk -v labels="$labels_yaml" '
    {
      if ($0 ~ /__dynamic_labels__/) {
        print labels
      } else {
        print
      }
    }' "${PROMTAIL_BASE_PATH}/etc/config-template.yaml" > "${PROMTAIL_BASE_PATH}/etc/config.yaml"
}

# ---------------------------------------------------------------------------------------
# promtail_initialize() - Initialize Promtail configuration
#
# @global PROMTAIL_* The PROMTAIL_* environment variables
# @return void
#
promtail_initialize() {
    info "Promtail: Initializing ..."

    info "Will scrape logs found at ${PROMTAIL_SCRAPE_PATH}"

    path=$(dirname "${PROMTAIL_SCRAPE_PATH}")
    if [ ! -d "$path" ]; then
      warn "$path does not exist"
    fi

    info "Logs will be sent to ${PROMTAIL_CLIENT_URL}"

    if [[ $PROMTAIL_BASIC_AUTH_USERNAME != "" && $PROMTAIL_BASIC_AUTH_PASSWORD != "" ]]; then
        info "Will authenticate with username ${PROMTAIL_BASIC_AUTH_USERNAME} and a given password"
    fi
    if [[ $PROMTAIL_BASIC_AUTH_USERNAME != "" && $PROMTAIL_BASIC_AUTH_PASSWORD == "" ]]; then
        warn "Authentication is configured to use username ${PROMTAIL_BASIC_AUTH_USERNAME} but no password was specified!"
    fi

    info "Generating configuration file"
    promtail_render_config

    info "Checking configuration syntax"
    "${PROMTAIL_BASE_PATH}/bin/promtail" -config.file=${PROMTAIL_BASE_PATH}/etc/config.yaml -check-syntax
}
