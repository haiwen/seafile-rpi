#!/bin/bash

cd $(dirname $0)

OUTPUT_DIR="./out"
mkdir $OUTPUT_DIR > /dev/null 2>&1

if [ -f "./compileSeafile_v${VERSION}.sh" ];then
    cmd="/compileSeafile.sh && chown -R $(id -u):$(id -g) /built-seafile-server-pkgs"
    USESCRIPT="v${VERSION}"
else
    cmd="/compileSeafile.sh ${VERSION} && chown -R $(id -u):$(id -g) /built-seafile-server-pkgs"
    USESCRIPT="default"
fi


docker run --rm \
    --platform linux/${2} \
    --pull missing \
    -v "./compileSeafile_${USESCRIPT}.sh":/compileSeafile.sh \
    -v "$OUTPUT_DIR/${2}/built-seafile-server-pkgs":/built-seafile-server-pkgs \
    seafile-builder:${1} /bin/bash -c "$cmd"
