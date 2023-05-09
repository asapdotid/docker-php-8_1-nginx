#!/bin/bash
set -o nounset -o errexit

# Load all variables .env
set -o allexport
source "$(dirname "$0")/.env"
set +o allexport

# Check first if docker image is exist
_OLD_IMAGE="$(docker images ls --filter=reference='$DOCKER_REGISTRY/$DOCKER_REGISTRY_USER/$DOCKER_REGISTRY_IMAGE:$DOCKER_REGISTRY_IMAGE_TAG' -q | wc -l)"
if [ "$_OLD_IMAGE" -ne 0 ]; then
    (exec docker rmi -f "$DOCKER_REGISTRY/$DOCKER_REGISTRY_USER/$DOCKER_REGISTRY_IMAGE:$DOCKER_REGISTRY_IMAGE_TAG") &
fi

# Run Build Docker Image
exec docker buildx build \
    -f $DOCKER_FILE \
    -t $DOCKER_REGISTRY/$DOCKER_REGISTRY_USER/$DOCKER_REGISTRY_IMAGE:$DOCKER_REGISTRY_IMAGE_TAG .
