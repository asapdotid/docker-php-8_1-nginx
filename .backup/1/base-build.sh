#!/bin/bash
set -e

if [[ -z "$1" ]]; then
    echo "Select option 1|2"
else
    docker build -t asapdotid/php-nginx-base:2-$1-test . -f base-$1.dockerfile
fi
