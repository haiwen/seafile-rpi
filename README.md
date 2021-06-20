Seafile server package for Raspberry Pi. Maintained by seafile community.

## Download

- The latest **stable** rpi version is [here](https://github.com/haiwen/seafile-rpi/releases/latest).

## Build
For Seafile versions which use Python 3. Seafile versions higher than 7.0.

E.g. to compile Seafile server v8.0.5:
```
$ wget https://raw.githubusercontent.com/haiwen/seafile-rpi/master/build3.sh
$ chmod u+x build3.sh
$ ./build3.sh -D -A -v 8.0.5
```
Calling `./build3.sh` without arguments will return usage information and a list of all available arguments.

Schema of created directory structure:
```
seafile@rpi-focal:~$ ll
total 20
-rwxrwxr-x 1 seafile seafile 17795 Jun 10 00:42 build3.sh
drwxrwxr-x 1 seafile seafile    60 Jun 10 00:21 built-seafile-server-pkgs
drwxrwxr-x 1 seafile seafile    12 Jun  9 23:41 built-seafile-sources
drwxrwxr-x 1 seafile seafile   160 Jun 10 00:16 haiwen-build
drwxrwxr-x 1 seafile seafile    10 Jun  9 22:36 opt
.
├── build3.sh
├── built-seafile-server-pkgs
│   └── seafile-server_8.0.5_pi.tar.gz
├── built-seafile-sources
│   └── R8.0.5
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

For Seafile versions which use Python 2. Seafile versions lower than 7.1, e.g. v7.0.5:
```
$ git clone https://github.com/haiwen/seafile-rpi.git
$ cd seafile-rpi
$ sudo ./build.sh
```

## Manual and Guides

- [Build Seafile server](https://manual.seafile.com/build_seafile/rpi/)
- [Deploy Seafile server](https://manual.seafile.com/deploy/)

## Reporting Issues / GitHub Issues

If you have any problems or suggestions when using the seafile rpi server package, please report it on [seafile server forum](https://forum.seafile.com/). 

**GitHub Issues support is dropped** and will not  be maintained anymore. If you need help, clarification or report some weird behaviour, please post it on the [seafile server forum](https://forum.seafile.com/) as well.

## Contributors

See [CONTRIBUTORS](https://github.com/haiwen/seafile-rpi/graphs/contributors).
