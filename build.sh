#!/usr/bin/env bash

set -eou pipefail

docker build --no-cache --tag lread/quick-gitweb:1.0.0 .
