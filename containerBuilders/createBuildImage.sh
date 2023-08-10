#!/bin/bash

#script parameters:
# createBuildImage.sh [distribution] [architecture] [GOpackage]
#e.g.
# createBuildImage.sh bookworm arm64 go1.20.4.linux-arm64.tar.gz
# createBuildImage.sh focal arm/v7 go1.20.4.linux-armv6l.tar.gz
#

cd $(dirname $0)
# Register/update emulators
docker run --rm --privileged tonistiigi/binfmt --install all >/dev/null

builder=multiarch_builder
# create multiarch builder if needed
if [ "$(docker buildx ls | grep $builder)" == "" ]
then
    docker buildx create --name $builder
fi
docker buildx use $builder

# Build image
docker buildx build -f "BuildImageDockerFiles/${1}_${2//\/}" --load --platform "linux/${2}" --build-arg GOVERSION=${3} -t "seafile-builder:${1}" -t "seafile-builder:latest" "."
