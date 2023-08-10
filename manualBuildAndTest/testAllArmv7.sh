#!/bin/bash

#this script tests all arm/v7 packages for all distributions that are currently supported

cd $(dirname $0)

./dockerReset.sh
../containerBuilders/createTestingImage.sh buster arm/v7
../testScripts/startServerPackageTest.sh buster arm/v7
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error while test"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createTestingImage.sh bullseye arm/v7
../testScripts/startServerPackageTest.sh bullseye arm/v7
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error while test"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createTestingImage.sh bookworm arm/v7
../testScripts/startServerPackageTest.sh bookworm arm/v7
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error while test"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createTestingImage.sh focal arm/v7
../testScripts/startServerPackageTest.sh focal arm/v7
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error while test"
  exit 1
fi

./dockerReset.sh
../containerBuilders/createTestingImage.sh jammy arm/v7
../testScripts/startServerPackageTest.sh jammy arm/v7
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Error while test"
  exit 1
fi

./dockerReset.sh
