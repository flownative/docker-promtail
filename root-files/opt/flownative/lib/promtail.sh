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
export PROMTAIL_LABEL_JOB="${PROMTAIL_LABEL_JOB:-promtail}"
export PROMTAIL_LABEL_HOST="${PROMTAIL_LABEL_HOST:-$(hostname)}"
export PROMTAIL_LABEL_ORGANIZATION="${PROMTAIL_LABEL_ORGANIZATION:-}"
export PROMTAIL_LABEL_PROJECT="${PROMTAIL_LABEL_PROJECT:-}"
export PROMTAIL_CLIENT_TENANT_ID="${PROMTAIL_CLIENT_TENANT_ID:-}"
export PROMTAIL_BASIC_AUTH_USERNAME="${PROMTAIL_BASIC_AUTH_USERNAME:-}"
export PROMTAIL_BASIC_AUTH_PASSWORD="${PROMTAIL_BASIC_AUTH_PASSWORD:-}"
export PROMTAIL_SCRAPE_PATH=${PROMTAIL_SCRAPE_PATH:-/application/Data/Logs/*.log}

export PATH="${PATH}:${PROMTAIL_BASE_PATH}/bin"
EOF
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

    path=$(dirname ${PROMTAIL_SCRAPE_PATH})
    if [ ! -d  $path ]; then
      warn "$path does not exist"
    fi

    info "Logs will be sent to ${PROMTAIL_CLIENT_URL}"

    if [[ $PROMTAIL_BASIC_AUTH_USERNAME != "" && $PROMTAIL_BASIC_AUTH_PASSWORD != "" ]]; then
        info "Will authenticate with username ${PROMTAIL_BASIC_AUTH_USERNAME} and a given password"
    fi
    if [[ $PROMTAIL_BASIC_AUTH_USERNAME != "" && $PROMTAIL_BASIC_AUTH_PASSWORD == "" ]]; then
        warn "Authentication is configured to use username ${PROMTAIL_BASIC_AUTH_USERNAME} but no password was specified!"
    fi
}
