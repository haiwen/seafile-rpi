#!/bin/bash
# Usage: ./build3.sh 8.0.2

#
# CONST
#

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
BUILDFOLDER=haiwen-build
THIRDPARTYFOLDER=$SCRIPTPATH/$BUILDFOLDER/seahub_thirdparty
PKGSOURCEDIR=built-seafile-sources
PKGDIR=built-seafile-server-pkgs
PREFIX=$HOME/opt/local
# Temporary folder for seafile-server dependency builds for shared libraries (ld)
# see https://github.com/haiwen/seafile-server/blob/193ec9381e8210f35fb9c416932b51c6166ebed6/scripts/build/build-server.py#L345

#LIBSEARPC_VERSION=3.1.0
LIBSEARPC_VERSION_LATEST=3.2-latest # check if new tag is available on https://github.com/haiwen/libsearpc/releases
LIBSEARPC_VERSION_FIXED=3.1.0 # libsearpc sticks to 3.1.0 https://github.com/haiwen/libsearpc/commit/43d768cf2eea6afc6e324c2b1a37a69cd52740e3
LIBSEARPC_TAG=v$LIBSEARPC_VERSION_LATEST
VERSION=${1:-'8.0.2'} # easily pass the Seafile server version to the build3.sh script
VERSION_TAG=v$VERSION-server
VERSION_CCNET=6.0.1 # ccnet has not consistent version (see configure.ac)
VERSION_SEAFILE=6.0.1 # ebenda for seafile
MYSQL_CONFIG_PATH=/usr/bin/mysql_config # ensure compilation with mysql support
#PYTHON_REQUIREMENTS_URL_SEAHUB=https://raw.githubusercontent.com/haiwen/seahub/master/requirements.txt  # official requirements.txt file
PYTHON_REQUIREMENTS_URL_SEAHUB=https://raw.githubusercontent.com/jobenvil/rpi-build-seafile/main/seahub_requirements_v8.0.3.txt # Only for build the 8.0.3 version
PYTHON_REQUIREMENTS_URL_SEAFDAV=https://raw.githubusercontent.com/haiwen/seafdav/master/requirements.txt

STEPS=13
STEPCOUNTER=0

mkdir -p $BUILDFOLDER

#
# START
#

echo_start()
{
  echo -e "\e[93mBuild seafile-rpi $VERSION_TAG\e[39m\n"
}

#
# INSTALL DEPENDENCIES
#

install_dependencies()
{
  STEPCOUNTER=$((STEPCOUNTER+1))
  echo -e "\n\e[93m-> [$STEPCOUNTER/$STEPS] Install dependencies\e[39m\n"

  # https://github.com/haiwen/seafile/issues/1158
  # onigposix (libonig-dev) is dependency for /usr/local/include/evhtp.h

  echo -e "\n\e[93mDownloads the package lists from the repositories and updates them\e[39m\n"
  (set -x; sudo apt-get update)
  echo -e "\n\e[93mInstall build-essential package\e[39m\n"
  (set -x; sudo apt-get install -y build-essential)
  echo -e "\n\e[93mInstall build dependencies\e[39m\n"
  (set -x; sudo apt-get install -y \
     cmake \
     git \
     intltool \
     libarchive-dev \
     libcurl4-openssl-dev \
     libevent-dev \
     libfuse-dev \
     libglib2.0-dev \
     libjansson-dev \
     libjpeg-dev \
     libldap2-dev \
     libmariadbclient-dev-compat \
     libonig-dev \
     libpq-dev \
     libsqlite3-dev \
     libssl-dev \
     libtool \
     libxml2-dev \
     libxslt-dev \
     python3-lxml \
     python3-pip \
     python3-setuptools \
     python3-wheel \
     uuid-dev \
     valac \
     wget)
}

#
# PREPARE build (without privileges)
#

prepare_build()
{
  STEPCOUNTER=$((STEPCOUNTER+1))
  echo -e "\n\e[93m-> [$STEPCOUNTER/$STEPS] Prepare build\e[39m\n"

  set -x
  mkdir -p $PREFIX
  export LIBRARY_PATH=$PREFIX/lib
  export LD_LIBRARY_PATH=$PREFIX/lib
  export CPATH=$PREFIX/include
  set +x
}

#
# BUILD libevhtp
#

build_libevhtp()
{
  STEPCOUNTER=$((STEPCOUNTER+1))
  echo -e "\n\e[93m-> [$STEPCOUNTER/$STEPS] Build libevhtp\e[39m\n"

  cd $BUILDFOLDER

  if [ -d "libevhtp" ]; then
    cd libevhtp
    (set -x; make clean)
    (set -x; git fetch origin --tags)
    (set -x; git reset --hard origin/master)
  else
    (set -x; git clone https://www.github.com/haiwen/libevhtp.git)
    cd libevhtp
  fi
  (set -x; cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DEVHTP_DISABLE_SSL=ON -DEVHTP_BUILD_SHARED=OFF .)
  (set -x; make)
  (set -x; make install)
  cd $SCRIPTPATH
}

#
# PREPARE libs
#

export_pkg_config_path()
{
  STEPCOUNTER=$((STEPCOUNTER+1))
  echo -e "\n\e[93m-> [$STEPCOUNTER/$STEPS] PREPARE libs\e[39m\n"
  # Export PKG_CONFIG_PATH for seafile-server, libsearpc and ccnet-server
  echo -e "\e[93m   Export PKG_CONFIG_PATH for seafile-server, libsearpc and ccnet-server\e[39m\n"
  export PKG_CONFIG_PATH=$SCRIPTPATH/$BUILDFOLDER/ccnet-server:$PKG_CONFIG_PATH
  export PKG_CONFIG_PATH=$SCRIPTPATH/$BUILDFOLDER/libsearpc:$PKG_CONFIG_PATH
  export PKG_CONFIG_PATH=$SCRIPTPATH/$BUILDFOLDER/seafile-server/lib:$PKG_CONFIG_PATH

  # print $PKG_CONFIG_PATH
  echo -e "\e[93m   PKG_CONFIG_PATH = $PKG_CONFIG_PATH \e[39m\n"
}

#
# BUILD libsearpc
#

build_libsearpc()
{
  STEPCOUNTER=$((STEPCOUNTER+1))
  echo -e "\n\e[93m-> [$STEPCOUNTER/$STEPS] Build libsearpc\e[39m\n"

  cd $BUILDFOLDER
  if [ -d "libsearpc" ]; then
    cd libsearpc
    (set -x; make clean && make distclean)
    (set -x; git fetch origin --tags)
    (set -x; git reset --hard origin/master)
  else
    (set -x; git clone https://github.com/haiwen/libsearpc.git)
    cd libsearpc
  fi
  (set -x; git reset --hard $LIBSEARPC_TAG)
  (set -x; ./autogen.sh)
  (set -x; ./configure)
  (set -x; make dist)
  cd $SCRIPTPATH
}

#
# BUILD ccnet
#

build_ccnet()
{
  STEPCOUNTER=$((STEPCOUNTER+1))
  echo -e "\n\e[93m-> [$STEPCOUNTER/$STEPS] Build ccnet-server\e[39m\n"

  cd $BUILDFOLDER
  if [ -d "ccnet-server" ]; then
    cd ccnet-server
    (set -x; make clean && make distclean)
    (set -x; git fetch origin --tags)
    (set -x; git reset --hard origin/master)
  else
    (set -x; git clone https://github.com/haiwen/ccnet-server.git)
    cd ccnet-server
  fi
  (set -x; git reset --hard $VERSION_TAG)
  (set -x; ./autogen.sh)
  (set -x; ./configure --with-mysql=$MYSQL_CONFIG_PATH)
  (set -x; make dist)
  cd $SCRIPTPATH
}

#
# BUILD seafile
#

build_seafile()
{
  STEPCOUNTER=$((STEPCOUNTER+1))
  echo -e "\n\e[93m-> [$STEPCOUNTER/$STEPS] Build seafile-server\e[39m\n"

  cd $BUILDFOLDER
  if [ -d "seafile-server" ]; then
    cd seafile-server
    (set -x; make clean && make distclean)
    (set -x; git fetch origin --tags)
    (set -x; git reset --hard origin/master)
  else
    (set -x; git clone https://github.com/haiwen/seafile-server.git)
    cd seafile-server
  fi
  (set -x; git reset --hard $VERSION_TAG)
  (set -x; ./autogen.sh)
  (set -x; ./configure --with-mysql=$MYSQL_CONFIG_PATH)
  (set -x; make dist)
  cd $SCRIPTPATH
}

#
# INSTALL thirdparty requirements
#

install_thirdparty()
{
  STEPCOUNTER=$((STEPCOUNTER+1))
  echo -e "\n\e[93m-> [$STEPCOUNTER/$STEPS] Install Seafile thirdparty requirements\e[39m\n"

  # add piwheels to pip
  echo -e "\e[93m   Add piwheels to pip\e[39m\n"
  echo "[global]" > /etc/pip.conf
  echo "extra-index-url=https://www.piwheels.org/simple" >> /etc/pip.conf

  # While pip alone is sufficient to install from pre-built binary archives, up to date copies of the setuptools and wheel projects are useful to ensure we can also install from source archives
  # e.g. default shipped pip=9.0.1 in Ubuntu Bionic => need update to pip=20.*
  # script executed like as seafile user, therefore pip upgrade only for seafile user, not system wide; pip installation goes to /home/seafile/.local/lib/python3.6/site-packages
  echo -e "\n\e[93m   Download and update pip(3), setuptools and wheel from PyPI\e[39m\n"
  (set -x; python3 -m pip install --user --upgrade pip setuptools wheel --no-warn-script-location)

  mkdir -p $THIRDPARTYFOLDER

  # get Seahub thirdparty requirements directly from GitHub
  echo -e "\n\e[93m   Get Seahub thirdparty requirements directly from GitHub\e[39m\n"
  (set -x; wget $PYTHON_REQUIREMENTS_URL_SEAHUB -O $THIRDPARTYFOLDER/requirements.txt)

  # get SeafDAV thirdparty requirements directly from Github
  echo -e "\n\e[93m   Get SeafDAV thirdparty requirements directly from GitHub\e[39m\n"
  (set -x; wget $PYTHON_REQUIREMENTS_URL_SEAFDAV -O $THIRDPARTYFOLDER/requirements_SeafDAV.txt)
  # merge seahub and seafdav requirements in one file
  (set -x; cat $THIRDPARTYFOLDER/requirements_SeafDAV.txt >> $THIRDPARTYFOLDER/requirements.txt)

  # install Seahub and SeafDAV thirdparty requirements
  # on pip=20.* DEPRECATION: --install-option: ['--install-lib', '--install-scripts']
  echo -e "\n\e[93m   Install Seahub and SeafDAV thirdparty requirements\e[39m\n"
  (set -x; python3 -m pip install -r $THIRDPARTYFOLDER/requirements.txt --target $THIRDPARTYFOLDER --no-cache --upgrade)

  # clean up
  echo -e "\n\e[93m   Clean up\e[39m\n"
  rm $THIRDPARTYFOLDER/requirements.txt $THIRDPARTYFOLDER/requirements_SeafDAV.txt
  rm -rf $(find . -name "__pycache__")
}

#
# BUILD seahub
#

build_seahub()
{
  STEPCOUNTER=$((STEPCOUNTER+1))
  echo -e "\n\e[93m-> [$STEPCOUNTER/$STEPS] Build seahub\e[39m\n"

  # get source code
  cd $BUILDFOLDER
  if [ -d "seahub" ]; then
    cd seahub
    (set -x; make clean)
    (set -x; git fetch origin --tags)
    (set -x; git reset --hard origin/master)
  else
    (set -x; git clone https://github.com/haiwen/seahub.git)
    cd seahub
  fi
  (set -x; git reset --hard $VERSION_TAG)

  # export $THIRDPARTYFOLDER to $PATH
  echo -e "\n\e[93m   Export THIRDPARTYFOLDER to PATH\e[39m\n"
  export PATH=$THIRDPARTYFOLDER:$PATH
  # print $PATH which includes now $THIRDPARTYFOLDER
  echo -e "\e[93m   PATH = $PATH\e[39m\n"

  # export $THIRDPARTYFOLDER to $PYTHONPATH
  echo -e "\e[93m   Export THIRDPARTYFOLDER to PYTHONPATH\e[39m\n"
  export PYTHONPATH=$THIRDPARTYFOLDER
  # print $PYTHONPATH
  echo -e "\e[93m   PYTHONPATH = $PYTHONPATH\e[39m"

  # to fix [ERROR] django-admin scripts not found in PATH
  echo -e "\n\e[93m   export THIRDPARTYFOLDER/django/bin to PATH\e[39m\n"
  export PATH=$THIRDPARTYFOLDER/django/bin:$PATH
  echo -e "\e[93m   PATH = $PATH\e[39m\n"

  # generate package
  # if python != python3.6 we need to "sudo ln -s /usr/bin/python3.6 /usr/bin/python" or with "pyenv global 3.6.9"
  (set -x; python3 $SCRIPTPATH/$BUILDFOLDER/seahub/tools/gen-tarball.py --version=$VERSION_SEAFILE --branch=HEAD)
  cd $SCRIPTPATH
}

#
# BUILD seafobj
#

build_seafobj()
{
  STEPCOUNTER=$((STEPCOUNTER+1))
  echo -e "\n\e[93m-> [$STEPCOUNTER/$STEPS] Build seafobj\e[39m\n"

  cd $BUILDFOLDER
  if [ -d "seafobj" ]; then
    cd seafobj
    (set -x; git fetch origin --tags)
    (set -x; git reset --hard origin/master)
  else
    (set -x; git clone https://github.com/haiwen/seafobj.git)
    cd seafobj
  fi
  (set -x; git reset --hard $VERSION_TAG)
  (set -x; make dist)
  cd $SCRIPTPATH
}

#
# BUILD seafdav
#

build_seafdav()
{
  STEPCOUNTER=$((STEPCOUNTER+1))
  echo -e "\n\e[93m-> [$STEPCOUNTER/$STEPS] Build seafdav\e[39m\n"

  cd $BUILDFOLDER
  if [ -d "seafdav" ]; then
    cd seafdav
    (set -x; git fetch origin --tags)
    (set -x; git reset --hard origin/master)
  else
    (set -x; git clone https://github.com/haiwen/seafdav.git)
    cd seafdav
  fi
  (set -x; git reset --hard $VERSION_TAG)
  (set -x; make)
  cd $SCRIPTPATH
}

#
# Copy package source
#

copy_pkg_source()
{
  STEPCOUNTER=$((STEPCOUNTER+1))
  echo -e "\n\e[93m-> [$STEPCOUNTER/$STEPS] Copy sources to $PKGSOURCEDIR/R$VERSION \e[39m\n"

  mkdir -p $PKGSOURCEDIR/R$VERSION
  (set -x; cp $BUILDFOLDER/libsearpc/libsearpc-$LIBSEARPC_VERSION_FIXED.tar.gz $PKGSOURCEDIR/R$VERSION)
  (set -x; cp $BUILDFOLDER/ccnet-server/ccnet-$VERSION_CCNET.tar.gz $PKGSOURCEDIR/R$VERSION)
  (set -x; cp $BUILDFOLDER/seafile-server/seafile-$VERSION_SEAFILE.tar.gz $PKGSOURCEDIR/R$VERSION)
  (set -x; cp $BUILDFOLDER/seahub/seahub-$VERSION_SEAFILE.tar.gz $PKGSOURCEDIR/R$VERSION)
  (set -x; cp $BUILDFOLDER/seafobj/seafobj.tar.gz $PKGSOURCEDIR/R$VERSION)
  (set -x; cp $BUILDFOLDER/seafdav/seafdav.tar.gz $PKGSOURCEDIR/R$VERSION)
}

#
# Build Seafile server
#

build_server()
{
  STEPCOUNTER=$((STEPCOUNTER+1))
  echo -e "\n\e[93m-> [$STEPCOUNTER/$STEPS] Build Seafile server\e[39m\n"

  mkdir -p $PKGDIR
  (set -x; python3 $SCRIPTPATH/$BUILDFOLDER/seafile-server/scripts/build/build-server.py \
    --libsearpc_version=$LIBSEARPC_VERSION_FIXED \
    --ccnet_version=$VERSION_CCNET \
    --seafile_version=$VERSION_SEAFILE \
    --version=$VERSION \
    --thirdpartdir=$THIRDPARTYFOLDER \
    --srcdir=$SCRIPTPATH/$PKGSOURCEDIR/R$VERSION \
    --mysql_config=$MYSQL_CONFIG_PATH \
    --outputdir=$SCRIPTPATH/$PKGDIR \
    --yes)
}

#
# COMPLETE
#

echo_complete()
{
  echo -e "\n\e[93m-> BUILD COMPLETED.\e[39m\n"
}

#
# MAIN
#

echo_start
install_dependencies
prepare_build
build_libevhtp

export_pkg_config_path

build_libsearpc
build_ccnet
build_seafile

install_thirdparty

build_seahub
build_seafobj
build_seafdav

copy_pkg_source
build_server
echo_complete
