#!/bin/bash

set -Eeo pipefail

set -a
[ -f .env ] && . .env
set +a

while getopts B:o:P:123456789ATv:r:f: flag
do
    case "${flag}" in
        B) BUILDER=$OPTARG;;
        o) OUTPUT_DIR=$OPTARG;;
        P) PLATFORMS=$OPTARG;;
        v) ARGS=$ARGS" -v $OPTARG";;
        1) ARGS=$ARGS" -1";;
        2) ARGS=$ARGS" -2";;
        3) ARGS=$ARGS" -3";;
        4) ARGS=$ARGS" -4";;
        5) ARGS=$ARGS" -5";;
        6) ARGS=$ARGS" -6";;
        7) ARGS=$ARGS" -7";;
        8) ARGS=$ARGS" -8";;
        9) ARGS=$ARGS" -9";;
        A) ARGS=$ARGS" -A";;
        T) ARGS=$ARGS" -T";;
        r) ARGS=$ARGS" -r $OPTARG";;
        f) ARGS=$ARGS" -f $OPTARG";;
        :) exit 1;;
        \?) exit 1;; 
    esac
done

if [ ! "$OUTPUT_DIR" ]; then OUTPUT_DIR="./build"; fi
if [ ! "$BUILDER" ]; then 
    echo "Builder not specified, abort..."
    exit 1
fi

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$ROOT_DIR"

OUTPUT_DIR="$ROOT_DIR/$OUTPUT_DIR"

IFS=',' read -r -a platforms <<< "$PLATFORMS"
for platform in "${platforms[@]}"
do
    distro="$(sed 's#linux/##' <<< $platform)"
    tag="$(sed 's#/##' <<< $distro)"

    if [ ! -d "$OUTPUT_DIR/$tag" ]; then
        mkdir -p "$OUTPUT_DIR/$tag"
    fi

    cmd="/build.sh $ARGS \
        && chown -R $(id -u):$(id -g) /built-seafile-server-pkgs"

    # cmd="/bin/bash"

    (set -x;
    docker run -it --rm \
        --platform $platform \
        --pull always \
        -v "$ROOT_DIR/build.sh":/build.sh \
        -v "$ROOT_DIR/requirements":/requirements \
        -v "$OUTPUT_DIR/$tag/haiwen-build":/haiwen-build \
        -v "$OUTPUT_DIR/$tag/built-seafile-sources":/built-seafile-sources \
        -v "$OUTPUT_DIR/$tag/root/opt/local":/root/opt/local \
        -v "$OUTPUT_DIR/$tag/built-seafile-server-pkgs":/built-seafile-server-pkgs \
        $BUILDER /bin/bash -c "$cmd")
done
