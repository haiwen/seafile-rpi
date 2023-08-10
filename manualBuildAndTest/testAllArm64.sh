#!/bin/bash

#this script tests all arm64 packages for all distributions that are currently supported

cd $(dirname $0)

./dockerReset.sh
../containerBuilders/createTestingImage.sh buster arm64
../testScripts/startServerPackageTest.sh buster arm64
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error while test"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createTestingImage.sh bullseye arm64
../testScripts/startServerPackageTest.sh bullseye arm64
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error while test"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createTestingImage.sh bookworm arm64
../testScripts/startServerPackageTest.sh bookworm arm64
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error while test"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createTestingImage.sh focal arm64
../testScripts/startServerPackageTest.sh focal arm64
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error while test"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createTestingImage.sh jammy arm64
../testScripts/startServerPackageTest.sh jammy arm64
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error while test"
  exit 1
fi

./dockerReset.sh
