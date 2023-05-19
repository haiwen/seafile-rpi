FROM --platform=$TARGETPLATFORM debian:buster

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    tzdata \
    wget \
    libmemcached-dev

# Install build dependencies
COPY ./build.sh ./build.sh
RUN ./build.sh -D
