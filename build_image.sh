#!/bin/bash

set -Eeo pipefail

set -a
[ -f .env ] && . .env
set +a

while getopts D:f:r:u:i:t:pP:l: flag
do
    case "${flag}" in
        D) DOCKERFILE_DIR=$OPTARG;;
        f) DOCKERFILE="$OPTARG";;
        r) REGISTRY="$OPTARG";;
        u) REPOSITORY=$OPTARG;;
        i) IMAGE=$OPTARG;;
        t) TAGS="$TAGS -t $([ "$REGISTRY" ] && echo $REGISTRY/)$REPOSITORY/$IMAGE:$OPTARG";;
        p) OUTPUT="--push";;
        P) PLATFORMS=$OPTARG;;
        l) OUTPUT="--load"; PLATFORMS="linux/$OPTARG";;
        :) exit 1;;
        \?) exit 1;; 
    esac
done

if [ ! "$DOCKERFILE_DIR" ]; then DOCKERFILE_DIR="."; fi
if [ ! "$DOCKERFILE" ]; then 
    echo "Dockerfile not specified, abort..."
    exit 1
fi

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$ROOT_DIR"

# Register/update emulators
docker run --rm --privileged tonistiigi/binfmt --install all >/dev/null

# Create custom network
network=seafile-builder
if [ ! "$(docker network ls -q --filter name=$network)" ]
then
    docker network create $network
fi

# Create local registry
if [ "$REGISTRY" = "registry:5000" ]
then
    registry_name=registry
    if [ ! "$(docker container ls -aq --filter name=$registry_name)" ]
    then
        docker run -d --name $registry_name -p 5000:5000 --network $network registry:2
    fi

    docker start $registry_name
fi

# create multiarch builder if needed
builder=multiarch_builder
if [ "$(docker buildx ls | grep $builder)" == "" ]
then
    docker buildx create --name $builder --driver-opt network=$network
fi

# Use the builder
docker buildx use $builder

set -x
# Build image
docker buildx build \
    -f "$DOCKERFILE" \
    $OUTPUT --platform "$PLATFORMS" $TAGS "$DOCKERFILE_DIR"
