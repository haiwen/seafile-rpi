#!/bin/bash

#this script builds all arm64 packages for all distributions that are currently supported

export VERSION=10.0.1

cd $(dirname $0)

./dockerReset.sh
../containerBuilders/createBuildImage.sh buster arm64 go1.20.4.linux-arm64.tar.gz
../compileScripts/buildServerPackage.sh buster arm64
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error when building"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createBuildImage.sh bullseye arm64 go1.20.4.linux-arm64.tar.gz
../compileScripts/buildServerPackage.sh bullseye arm64
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error when building"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createBuildImage.sh bookworm arm64 go1.20.4.linux-arm64.tar.gz
../compileScripts/buildServerPackage.sh bookworm arm64
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error when building"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createBuildImage.sh focal arm64 go1.20.4.linux-arm64.tar.gz
../compileScripts/buildServerPackage.sh focal arm64
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error when building"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createBuildImage.sh jammy arm64 go1.20.4.linux-arm64.tar.gz
../compileScripts/buildServerPackage.sh jammy arm64
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error when building"
  exit 1
fi

./dockerReset.sh
