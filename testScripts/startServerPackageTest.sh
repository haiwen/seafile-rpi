#!/bin/bash

#this script starts the prepared test container and tests the server package
#script parameters:
# startServerPackageTest.sh [distribution] [architecture]
#e.g.
# startServerPackageTest.sh buster arm64
# startServerPackageTest.sh focal arm/v7
#
# the compiled server package is expected to be in the directory ../out, which is the case
# if the compile scripts of this repo were used

cd $(dirname $0)
MY_DIR=$(pwd)
PACKAGE_DIR="../out"
cd $PACKAGE_DIR
PACKAGE_DIR=$(pwd)
cd $MY_DIR

if [ -f "./runTest_v${VERSION}.sh" ];then
    cmd="/runTest.sh"
    USESCRIPT="v${VERSION}"
else
    cmd="/runTest.sh ${VERSION}"
    USESCRIPT="default"
fi


SERVER_PACKAGE=$(find $PACKAGE_DIR/$2 -type f -iname "*.tar.gz" 2>/dev/null | grep $1 2>/dev/null)
SERVER_PACKAGE_FILENAME=$(basename $SERVER_PACKAGE)

docker run --rm \
    --platform linux/${2} \
    --pull missing \
    -v "./runTest_${USESCRIPT}.sh":/runTest.sh \
    --mount type=bind,src="$SERVER_PACKAGE",dst="/PACKAGE_DIR/$SERVER_PACKAGE_FILENAME" \
    seafile-testing:${1} /bin/bash -c "$cmd"
