Seafile server package for Raspberry Pi. Maintained by seafile community.

## Download

- The latest **stable** rpi version is 7.0.5, [click here to download](https://github.com/haiwen/seafile-rpi/releases/download/v7.0.5/seafile-server_7.0.5_stable_pi.tar.gz).

## Build
For Sefile versions which use Python 3. Seafile versions higher than 7.0.

E.g. to compile Seafile server v7.1.4:
```
$ wget https://github.com/haiwen/seafile-rpi/blob/master/build3.sh
$ chmod u+x build3.sh
$ ./build3.sh 7.1.4
```
Schema of created directory structure
```
seafile@rpi-bionic:~$ ll
-rwxr--r-- 1 seafile seafile 7391 May 20 21:44 build3.sh
drwxr-xr-x 1 seafile seafile   60 May 20 21:18 built-seafile-server-pkgs
drwxr-xr-x 1 seafile seafile  214 May 20 21:14 built-seafile-sources
drwxr-xr-x 1 seafile seafile  160 May 20 21:14 haiwen-build
.
├── built-seafile-server-pkgs
├── built-seafile-sources
└── haiwen-build
    ├── ccnet-server
    ├── libevhtp
    ├── libsearpc
    ├── seafdav
    ├── seafile-server
    ├── seafobj
    ├── seahub
    └── seahub_thirdparty
```

For Sefile versions which use Python 2. Seafile versions lower than 7.1, e.g. v7.0.5:
```
$ git clone https://github.com/haiwen/seafile-rpi.git
$ cd seafile-rpi
$ sudo ./build.sh
```

## Manual and Guides

- [Seafile Offical Document](http://manual.seafile.com/deploy/using_sqlite.html)

## Reporting Issues / GitHub Issues

If you have any problems or suggestions when using the seafile rpi server package, please report it on [seafile server forum](https://forum.seafile.com/). 

**GitHub Issues support is dropped** and will not  be maintained anymore. If you need help, clarification or report some weird behaviour, please post it on the [seafile server forum](https://forum.seafile.com/) as well.

## Contributors

See [CONTRIBUTORS](CONTRIBUTORS).
