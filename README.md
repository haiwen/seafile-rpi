Seafile server package for Raspberry Pi. Maintained by seafile community.

## Download

- The latest **stable** rpi version is [here](https://github.com/haiwen/seafile-rpi/releases/latest).

## Build
For Seafile versions which use Python 3. Seafile versions higher than 7.0.

E.g. to compile Seafile server v9.0.1:
```
$ wget https://raw.githubusercontent.com/haiwen/seafile-rpi/master/build3.sh
$ chmod u+x build3.sh
$ ./build3.sh -D -A -v 9.0.1
```
Calling `./build3.sh` without arguments will return usage information and a list of all available arguments.

Schema of created directory structure:
```
seafile@rpi-focal:~$ ll
-rwxr--r-- 1 seafile seafile 20803 Dec  3 11:41 build3.sh
-rw-r--r-- 1 seafile seafile  3029 Dec  4 11:53 build-server.py.patch
drwxr-xr-x 1 seafile seafile   120 Dec  4 12:29 built-seafile-server-pkgs
drwxr-xr-x 1 seafile seafile    36 Nov 30 18:26 built-seafile-sources
drwxr-xr-x 1 seafile seafile     6 Nov 29 17:38 go
drwxr-xr-x 1 seafile seafile   136 Dec  2 23:46 haiwen-build
drwxr-xr-x 1 seafile seafile    10 Nov 13 18:35 opt
.
├── build3.sh
├── build-server.py.patch
├── built-seafile-server-pkgs
│   └── seafile-server-9.0.1-focal-armv7l.tar.gz
├── built-seafile-sources
│   └── R9.0.1
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
├── opt
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
