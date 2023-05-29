#!/bin/bash

./dockerReset.sh
./createBuildImage.sh buster arm/v7 go1.20.4.linux-armv6l.tar.gz
VERSION=10.0.1 ./buildServerPackage.sh buster arm/v7
./dockerReset.sh
./createBuildImage.sh bullseye arm/v7 go1.20.4.linux-armv6l.tar.gz
VERSION=10.0.1 ./buildServerPackage.sh bullseye arm/v7
./dockerReset.sh
./createBuildImage.sh bookworm arm/v7 go1.20.4.linux-armv6l.tar.gz
VERSION=10.0.1 ./buildServerPackage.sh bookworm arm/v7
./dockerReset.sh
./createBuildImage.sh focal arm/v7 go1.20.4.linux-armv6l.tar.gz
VERSION=10.0.1 ./buildServerPackage.sh focal arm/v7
./dockerReset.sh
./createBuildImage.sh jammy arm/v7 go1.20.4.linux-armv6l.tar.gz
VERSION=10.0.1 ./buildServerPackage.sh jammy arm/v7
./dockerReset.sh
