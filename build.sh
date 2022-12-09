#!/bin/bash
set -e

docker build -t asapdotid/php-nginx-base:1.0.0-test . -f Dockerfile
