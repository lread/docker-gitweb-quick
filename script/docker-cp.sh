#!/usr/bin/env bash

set -ou pipefail

from=$1
to=$2

attempts_left=30

echo "docker cp ${from} ${to}"
until [ "$attempts_left" = 0 ]
do
    if docker cp "${from}" "${to}"; then
        break;
    else
        attempts_left=$((attempts_left -1))
        echo "- attempts left: ${attempts_left}"
        sleep 1;
    fi
done;

if [ "$attempts_left" = 0 ]; then
    echo "* error: attempts depleted"
    exit 1
else
    echo "- success"
    exit 0
fi
