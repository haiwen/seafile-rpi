#!/bin/bash

#this script starts the prepared build container and the compiling process for building the package
#script parameters: (the script expects the version to build as environment variable)
# VERSION=[seafile-version] buildServerPackage.sh [distribution] [architecture]
#e.g.
# VERSION=10.0.1 buildServerPackage.sh buster arm64
# VERSION=10.0.1 buildServerPackage.sh focal arm/v7
#
# the package is output in the directory ../out

ls -lisa
cd $(dirname $0)
ls -lisa
OUTPUT_DIR="../out"
mkdir $OUTPUT_DIR > /dev/null 2>&1
cd $OUTPUT_DIR
ls -lisa
OUTPUT_DIR=$(pwd)
ls -lisa
cd $(dirname $0)

if [ -f "./compileSeafile_v${VERSION}.sh" ];then
    cmd="/compileSeafile.sh && chown -R $(id -u):$(id -g) /built-seafile-server-pkgs"
    USESCRIPT="v${VERSION}"
else
    cmd="/compileSeafile.sh ${VERSION} && chown -R $(id -u):$(id -g) /built-seafile-server-pkgs"
    USESCRIPT="default"
fi


docker run --rm \
    --platform linux/${2} \
    -m 6192M \
    --pull missing \
    --mount type=bind,src="./compileSeafile_${USESCRIPT}.sh",dst="/compileSeafile.sh" \
    -v "$OUTPUT_DIR/${2}/built-seafile-server-pkgs":/built-seafile-server-pkgs \
    seafile-builder:${1} /bin/bash -c "$cmd"

