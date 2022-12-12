#!/bin/sh
set -o nounset -o errexit

# Load all variables .env
set -o allexport
source "$(dirname "$0")/.env"
set +o allexport

# Run Push Docker Image
exec docker image push "$DOCKER_REGISTRY/$DOCKER_REGISTRY_USER/$DOCKER_REGISTRY_IMAGE:$DOCKER_REGISTRY_IMAGE_TAG"
