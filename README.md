# TODO
TODO: **MUCH** more descriptions.  

Seafile server package for ARM.

## Download

- The latest **stable** arm versions are [here](TODO).

## Building
The build process requires docker to be installed. It has only been tests on x86_x64 machines.  
It is designed to run with Github actions but can also be run manually.  
Two steps are needed to build a server package:  
1. Create docker build image that is used to compile the seafile server for the needed distribution and architecture.  
2. Use the docker build image to actually compile the seafile server and create a .tar.gz file  

### Build manually
Clone this repository. Make sure docker is installed.  
Make sure you know the distribution and architecture you want to build for.  
Check if a Dockerfile for your distribution and archictecture already exists in githubActionsBuild/BuildImageDockerFiles. If not create a new one based on one of the most fitting of the existing ones and edit as needed.  
1. Create a docker build image  

```
./githubActionsBuild/createBuildImage.sh [DISTRO] [ARCH] [GOFILE]

The GOFILE is the filename to download from https://go.dev and will be used instead of the distributions go. Linking for go parts of seafile are static so they will run independent of the distributions go.

e.g. to build for jammy arm64 and with go 1.20.4
./githubActions/createBuildImage.sh jammy arm64 go1.20.4.linux-arm64.tar.gz

e.g. to build for bullseye arm/v7 and with go 1.20.4
./githubActions/createBuildImage.sh bullseye arm/v7 go1.20.4.linux-armv6l.tar.gz
```


2. Compile seafile server package
```
VERSION=[SEAFILE_VERSION] ./githubActionsBuild/buildServerPackage.sh [DISTRO] [ARCH]

The SEAFILE_VERSION is the version you want to compile.

e.g. to build 10.0.1 for jammy arm64
VERSION=10.0.1 ./githubActions/buildServerPackage.sh jammy arm64

e.g. to build 10.0.1 for bullseye arm/v7
VERSION=10.0.1 ./githubActions/buildServerPackage.sh bullseye arm/v7

```

### Build Online
Just execute the action and take the tar.gz files from the generated artifacts.

## Internals
