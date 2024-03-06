Seafile server package for Raspberry Pi. Maintained by seafile community.

## Download

- The latest **stable** rpi version is [here](https://github.com/haiwen/seafile-rpi/releases/latest).

## Build

E.g. to compile Seafile server v11.0.5:

```shell
$ wget https://raw.githubusercontent.com/haiwen/seafile-rpi/master/build.sh
$ chmod u+x build.sh
$ sudo ./build.sh -DTA -v 11.0.5 -h https://raw.githubusercontent.com/haiwen/seafile-rpi/master/requirements/seahub_requirements_v11.0.5.txt -d https://raw.githubusercontent.com/haiwen/seafile-rpi/master/requirements/seafdav_requirements_v11.0.5.txt
```

Calling `./build.sh` without arguments will return usage information and a list of all available arguments:

```shell
seafile@rpi-focal:~$ sudo ./build.sh

Usage:
  build.sh [OPTIONS]

  OPTIONS:
    -D          Install build dependencies
    -T          Install thirdparty requirements

    -0          Build/update libevhtp
    -1          Build/update libsearpc
    -2          Build/update seafile (c_fileserver)
    -3          Build/update seafile (go_fileserver)
    -4          Build/update seafile (notification_server)
    -5          Fetch/update seafevents
    -6          Build/update seahub
    -7          Build/update seafobj
    -8          Build/update seafdav
    -9          Build/update Seafile server

    -A          All options -0 to -9 in one go

    -v <vers>   Set seafile server version to build
                default: 11.0.5
    -r <vers>   Set libsearpc version
                default: 3.3-latest
    -f <vers>   Set fixed libsearpc version
                default: 3.1.0
    -h <vers>   Set python requirement file for seahub
                default: https://raw.githubusercontent.com/haiwen/seahub/v11.0.5-server/requirements.txt
    -d <vers>   Set python requirement file for seafdav
                default: https://raw.githubusercontent.com/haiwen/seafdav/v11.0.5-server/requirements.txt

    use --version for version info of this script.
```

Schema of created directory structure after execution of `./build.sh`:

```
seafile@rpi-jammy:~$ tree . -L 3
.
├── build.sh
├── built-seafile-server-pkgs
│   └── seafile-server-11.0.5-jammy-armv7l.tar.gz
├── built-seafile-sources
│   └── R11.0.5
├── go
│   └── pkg
├── haiwen-build
│   ├── libevhtp
│   ├── libsearpc
│   ├── seafdav
│   ├── seafevents
│   ├── seafile-server
│   ├── seafobj
│   ├── seahub
│   └── seahub_thirdparty
└── opt
    └── local
```

## Batch Build

If you want to build for multiple distributions and architectures via lxc containers you can run:

```shell
$ wget https://raw.githubusercontent.com/haiwen/seafile-rpi/master/build-batch.sh
$ chmod u+x build-batch.sh
$ sudo time bash ./build-batch.sh 10.0.1
```

Edit the script in order to build for your preferred distributions.

If want to execute the script in the background with logs written to `build-batch.log` call:
```shell
sudo su
nohup bash -c "sudo time bash ./build-batch.sh 9.0.9" >build-batch.log 2>build-batch.log < /dev/null &
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
