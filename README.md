# TODO

Seafile server package for Raspberry Pi. Maintained by seafile community.

## Download

- The latest **stable** rpi version is [here](https://github.com/haiwen/seafile-rpi/releases/latest).

## Build
The build process requires docker to be installed. It has only been tests on x86_x64 machines.  
It is designed to run with Github actions but can also be run manually.  
  
Two steps are needed to build a server package:  
1. Create docker build image that is used to compile the seafile server for the needed distribution and architecture.  
2. Use the docker build image to actually compile the seafile server and create a .tar.gz file  

### 1. Create a docker build image

### 2. Compile seafile server package

