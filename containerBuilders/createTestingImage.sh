#!/bin/bash

#script parameters:
# createTestingImage.sh [distribution] [architecture]
#e.g.
# createTestingImage.sh bookworm arm64
# createTestingImage.sh focal arm/v7
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
docker buildx build -f "TestingImageDockerFiles/${1}_${2//\/}" --load --platform "linux/${2}" -t "seafile-testing:${1}" -t "seafile-testing:latest" "."
