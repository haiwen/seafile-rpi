#!/bin/bash

cd $(dirname $0)

PACKAGE_DIR="./in"
mkdir $PACKAGE_DIR > /dev/null 2>&1

if [ -f "./runTest_v${VERSION}.sh" ];then
    cmd="/runTest.sh"
    USESCRIPT="v${VERSION}"
else
    cmd="/runTest.sh ${VERSION}"
    USESCRIPT="default"
fi

docker run --rm \
    --platform linux/${2} \
    --pull missing \
    -v "./runTest_${USESCRIPT}.sh":/runTest.sh \
    -v "$PACKAGE_DIR":/PACKAGE_DIR \
    seafile-testing:${1} /bin/bash -c "$cmd"

#docker run -it --rm \
#    --platform linux/${2} \
#    --pull missing \
#    -v "./runTest_${USESCRIPT}.sh":/runTest.sh \
#    -v "$PACKAGE_DIR":/PACKAGE_DIR \
#    seafile-testing:${1} /bin/bash
