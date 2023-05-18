Seafile server package for Raspberry Pi. Maintained by seafile community.

## Download

- The latest **stable** rpi version is [here](https://github.com/haiwen/seafile-rpi/releases/latest).

## Build

E.g. to compile Seafile server v10.0.1:

```shell
$ git clone --depth=1 https://github.com/haiwen/seafile-rpi.git && cd seafile-rpi
$ chmod u+x build.sh
$ sudo ./build.sh -DTA -v 10.0.1
```

Calling `./build.sh` without arguments will return usage information and a list of all available arguments:

```shell
seafile@rpi-focal:~$ sudo ./build.sh

Usage:
  build.sh [OPTIONS]

  OPTIONS:
    -D          Install build dependencies
    -T          Install thirdparty requirements

    -1          Build/update libevhtp
    -2          Build/update libsearpc
    -3          Build/update seafile (c_fileserver)
    -4          Build/update seafile (go_fileserver)
    -5          Build/update seafile (notification_server)
    -6          Build/update seahub
    -7          Build/update seafobj
    -8          Build/update seafdav
    -9          Build/update Seafile server

    -A          All options -1 to -9 in one go

    -v <vers>   Set seafile server version to build
                default: 10.0.1
    -r <vers>   Set libsearpc version
                default: 3.3-latest
    -f <vers>   Set fixed libsearpc version
                default: 3.1.0

    use --version for version info of this script.
```

Schema of created directory structure after execution of `./build.sh`:

```
seafile@rpi-focal:~$ tree . -L 3
.
├── build.sh
├── build-server.py.patch
├── built-seafile-server-pkgs
│   └── seafile-server-10.0.1-focal-armv7l.tar.gz
├── built-seafile-sources
│   └── R10.0.1
├── go
│   └── pkg
├── haiwen-build
│   ├── libevhtp
│   ├── libsearpc
│   ├── seafdav
│   ├── seafile-server
│   ├── seafobj
│   ├── seahub
│   └── seahub_thirdparty
└── opt
    └── local
```

## Docker build

This section describes cross-compilation using Docker buildx.

### Builder image creation

Copy the `.env.example` to `.env` and choose which image to build, for which platforms and to which place to push it. 

Then use the `build_image.sh` script to build it, for example to build an image tagged *jammy* and push it to the registry:

```bash
./build_image.sh -t jammy -p
```

Script reference:

```
build_image.sh [OPTIONS]

Command line arguments take precedence over settings defined in the .env file

Options:
    -f <path>       Set the Dockerfile to use
    -D <path>       Build directory (default: current directory)
    -P <platforms>  List of platforms to build, comma separated. Incompatible with -l. Example:
                      linux/arm64,linux/arm/v7
                    
    -r <registry>   Registry to which upload the image. Empty for Docker Hub. Need to be set before -t.
    -u <repo>       Repository to which upload the image. Need to be set before -t.
    -i <name>       Image name. Need to be set before -t.
    -t <tag>        Add a tag. Can be used several times

    -l <platform>   Load to the local images. One <platform> at time only.
                    <platform> working choices can be: 
                        arm/v7 
                        arm64 
                        amd64
    -p              Push the image(s) to the remote registry. Incompatible with -l.
```

### Build

Again, use the `.env` to set your parametets, i.e. Seafile version and builder image. The use the `build_with_docker.sh` script to build packages. Basically just a wrapper over `build.sh` for cross-compilation. You'll need one or more working builder images (see above).

What you *want* is probably just building in one pass:

```bash
$ ./build_with_docker.sh -TA
```

Package will be stored in the `build/<platform>/built-seafile-server-pkgs` folder.

But things can become a little more tricky. Golang parts (fileserver & notification server) typically won't build with an image based on a distribution older than Ubuntu 22.04 (jammy). Since go binaries are statically linked, you can use two builders to achieve your goal:

```bash
$ ./build_with_docker.sh -B localhost:5000/seafile/builder:jammy  -45
$ ./build_with_docker.sh -B localhost:5000/seafile/builder:buster -T1236789
```

Script reference:

```
build_with_docker.sh [OPTIONS]

Command line arguments take precedence over settings defined in the .env file

Options:
    -B <image>  Builder image to use       

    -T          Install thirdparty requirements

    -1          Build/update libevhtp
    -2          Build/update libsearpc
    -3          Build/update seafile (c_fileserver)
    -4          Build/update seafile (go_fileserver)
    -5          Build/update seafile (notification_server)
    -6          Build/update seahub
    -7          Build/update seafobj
    -8          Build/update seafdav
    -9          Build/update Seafile server

    -A          All options -1 to -9 in one go

    -v <vers>   Set seafile server version to build
                default: 10.0.1
    -r <vers>   Set libsearpc version
                default: 3.3-latest
    -f <vers>   Set fixed libsearpc version
                default: 3.1.0
```

## Manual and Guides

- [Build Seafile server](https://manual.seafile.com/build_seafile/rpi/)
- [Deploy Seafile server](https://manual.seafile.com/deploy/)

## Reporting Issues / GitHub Issues

If you have any problems or suggestions when using the seafile rpi server package, please report it
on [seafile server forum](https://forum.seafile.com/).

**GitHub Issues support is dropped** and will not be maintained anymore. If you need help, clarification or report some
weird behaviour, please post it on the [seafile server forum](https://forum.seafile.com/) as well.

## Contributors

See [CONTRIBUTORS](https://github.com/haiwen/seafile-rpi/graphs/contributors).
