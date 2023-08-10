#!/bin/bash

#this script builds all arm/v7 packages for all distributions that are currently supported

export VERSION=10.0.1

cd $(dirname $0)

./dockerReset.sh
../containerBuilders/createBuildImage.sh buster arm/v7 go1.20.4.linux-armv6l.tar.gz
../compileScripts/buildServerPackage.sh buster arm/v7
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error when building"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createBuildImage.sh bullseye arm/v7 go1.20.4.linux-armv6l.tar.gz
../compileScripts/buildServerPackage.sh bullseye arm/v7
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error when building"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createBuildImage.sh bookworm arm/v7 go1.20.4.linux-armv6l.tar.gz
../compileScripts/buildServerPackage.sh bookworm arm/v7
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error when building"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createBuildImage.sh focal arm/v7 go1.20.4.linux-armv6l.tar.gz
../compileScripts/buildServerPackage.sh focal arm/v7
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error when building"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createBuildImage.sh jammy arm/v7 go1.20.4.linux-armv6l.tar.gz
../compileScripts/buildServerPackage.sh jammy arm/v7
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error when building"
  exit 1
fi

./dockerReset.sh
