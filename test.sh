#!/usr/bin/env bash

set -eou pipefail

PORT=3000
REPO_DIR="${1:-}"
if [ -z "${REPO_DIR}" ]; then
    REPO_DIR=$(pwd)
else
    if [[ ! -d "${REPO_DIR}" ]]; then
        echo "* Error: directory not found: ${REPO_DIR}"
        exit 1
    fi
    REPO_DIR="$(cd "$(dirname "${REPO_DIR}")" && pwd -P)/$(basename "${REPO_DIR}")"
fi

echo "Running quick-gitweb against ${REPO_DIR} on port ${PORT}"

docker run \
       --rm \
       -i -t \
       -p "${PORT}:1234" \
       -v "${REPO_DIR}:/repo:ro" \
       lread/quick-gitweb:1.0.0
