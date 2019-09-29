# Build

```
$ sudo ./build.sh
```

Please check [the official document](http://manual.seafile.com/build_seafile/rpi.html)

# Release a new version

- Make sure the package has been tested
- Create a new release on https://github.com/haiwen/seafile-rpi/releases/new
- Release title should be like "Seafile server 4.1.2 for Raspberry Pi"
- Upload the packages there.
- After uploading, update the version number and download link in [REAME.md](README.md).

# Common problems and solutions

## Not enough memory to build lxml package

symptoms:
```
Processing lxml-4.4.1.tar.gz
aarch64-linux-gnu-gcc: internal compiler error: Killed (program cc1)
```

solution: Increase available memory by using a [swap file](https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-18-04)

## Unknown seahub error while gunicorn starting

symptoms: fails with no console message
solution: temporary comment 'Daemon=True' line in gunicorn.conf and start seahub again
