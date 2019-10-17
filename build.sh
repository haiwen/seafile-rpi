#!/bin/sh

#
# CONST
#

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
BUILDFOLDER=build
THIRDPARTYFOLDER=$SCRIPTPATH/$BUILDFOLDER/seahub_thirdparty
PKGSOURCEDIR=seafile-sources
PKGDIR=seafile-server-pkgs

LIBSEARPC_VERSION=3.1.0
LIBSEARPC_TAG=v$LIBSEARPC_VERSION
VERSION=7.0.5
VERSION_TAG=v$VERSION-server
VERSION_CCNET=6.0.1 # seafile/ccnet has not consistent version (see configure.ac)
VERSION_SEAFILE=6.0.1

STEPS=10

mkdir -p $BUILDFOLDER

#
# INSTALL DEPENDENCIES
#

install_dependencies()
{
  echo
  echo -e "\e[93m-> [1/$STEPS] Install dependencies\e[39m"

  # https://github.com/haiwen/seafile/issues/1158
  # onigposix (libonig-dev) is dependency for /usr/local/include/evhtp.h

  apt-get update
  apt-get install -y build-essential
  apt-get install -y \
    libevent-dev \
    libcurl4-openssl-dev \
    libglib2.0-dev \
    uuid-dev \
    intltool \
    libsqlite3-dev \
    libmysqlclient-dev \
    libarchive-dev \
    libtool \
    libjansson-dev \
    valac \
    libfuse-dev \
    re2c \
    flex \
    python-setuptools \
    cmake \
    libpq-dev \
    ldap-client \
    libldap-dev \
    libonig-dev
}

#
# BUILD libevhtp
#

build_libevhtp()
{
  echo
  echo -e "\e[93m-> [2/$STEPS] Build libevhtp\e[39m"

  cd $BUILDFOLDER

  if [ -d "libevhtp" ]; then
    cd libevhtp
    git reset --hard origin/master
    git pull
  else
    git clone https://www.github.com/haiwen/libevhtp.git
    cd libevhtp
  fi
  cmake -DEVHTP_DISABLE_SSL=ON -DEVHTP_BUILD_SHARED=OFF .
  make
  make install
  cd $SCRIPTPATH

  # update system lib cache
  ldconfig
}

# PREPARE libs

export_python_path()
{
  export PKG_CONFIG_PATH=$SCRIPTPATH/$BUILDFOLDER/seafile-server/lib:$PKG_CONFIG_PATH
  export PKG_CONFIG_PATH=$SCRIPTPATH/$BUILDFOLDER/libsearpc:$PKG_CONFIG_PATH
  export PKG_CONFIG_PATH=$SCRIPTPATH/$BUILDFOLDER/ccnet-server:$PKG_CONFIG_PATH
}

# BUILD libsearpc

build_libsearpc()
{
  echo
  echo -e "\e[93m-> [3/$STEPS] Build libsearpc\e[39m"

  cd $BUILDFOLDER
  if [ -d "libsearpc" ]; then
    cd libsearpc
    git reset --hard origin/master
    git pull
  else
    git clone https://github.com/haiwen/libsearpc.git
    cd libsearpc
  fi
  git reset --hard $LIBSEARPC_TAG
  ./autogen.sh
  ./configure
  make dist
  cd $SCRIPTPATH
}

# BUILD ccnet

build_ccnet()
{
  echo
  echo -e "\e[93m-> [4/$STEPS] Build ccnet-server\e[39m"

  cd $BUILDFOLDER
  if [ -d "ccnet-server" ]; then
    cd ccnet-server
    git reset --hard origin/master
    git pull
  else
    git clone https://github.com/haiwen/ccnet-server.git
    cd ccnet-server
  fi
  git reset --hard $VERSION_TAG
  ./autogen.sh
  ./configure
  make dist
  cd $SCRIPTPATH
}

# BUILD seafile

build_seafile()
{
  echo
  echo -e "\e[93m-> [5/$STEPS] Build seafile-server\e[39m"

  cd $BUILDFOLDER
  if [ -d "seafile-server" ]; then
    cd seafile-server
    git reset --hard origin/master
    git pull
  else
    git clone https://github.com/haiwen/seafile-server.git
    cd seafile-server
  fi
  git reset --hard $VERSION_TAG
  ./autogen.sh
  ./configure
  make dist
  cd $SCRIPTPATH
}

# BUILD seahub

build_seahub()
{
  echo
  echo -e "\e[93m-> [6/$STEPS] Build seahub\e[39m"

  export PATH=$THIRDPARTYFOLDER:$PATH

  # get source code
  cd $BUILDFOLDER
  if [ -d "seahub" ]; then
    cd seahub
    git reset --hard origin/master
    git pull
  else
    git clone https://github.com/haiwen/seahub.git
    cd seahub
  fi
  git reset --hard $VERSION_TAG

  # get and build python dependencies
  apt-get install libxml2-dev libxslt-dev

  mkdir -p $THIRDPARTYFOLDER
  export PYTHONPATH=$THIRDPARTYFOLDER

  if ! [ -x "$(command -v easy_install)" ]; then
    pip install easy_install
  fi
  while read line; do easy_install -d $THIRDPARTYFOLDER $line; done < requirements.txt

  # temporary fix for 7.0.4
  easy_install -d $THIRDPARTYFOLDER flup==1.0.2 SQLAlchemy==1.3.5 django_picklefield==2.0 urllib3==1.22

  # generate package
  ./tools/gen-tarball.py --version=$VERSION_SEAFILE --branch=HEAD
  cd $SCRIPTPATH
}

# BUILD seafobj

build_seafobj()
{
  echo
  echo -e "\e[93m-> [7/$STEPS] Build seafobj\e[39m"

  cd $BUILDFOLDER
  if [ -d "seafobj" ]; then
    cd seafobj
    git reset --hard origin/master
    git pull
  else
    git clone https://github.com/haiwen/seafobj.git
    cd seafobj
  fi
  git reset --hard $VERSTION_TAG
  make dist
  cd $SCRIPTPATH
}

# BUILD seafdav

build_seafdav()
{
  echo
  echo -e "\e[93m-> [8/$STEPS] Build seafdav\e[39m"

  cd $BUILDFOLDER
  if [ -d "seafdav" ]; then
    cd seafdav
    git reset --hard origin/master
    git pull
  else
    git clone https://github.com/haiwen/seafdav.git
    cd seafdav
  fi
  git reset --hard $VERSION_TAG
  make
  cd $SCRIPTPATH
}

#
# Copy package source
#

copy_pkg_source()
{
  echo
  echo -e "\e[93m-> [9/$STEPS] Copy sources\e[39m"

  mkdir -p $PKGSOURCEDIR
  cp $BUILDFOLDER/libsearpc/libsearpc-$LIBSEARPC_VERSION.tar.gz $PKGSOURCEDIR
  cp $BUILDFOLDER/ccnet-server/ccnet-$VERSION_CCNET.tar.gz $PKGSOURCEDIR
  cp $BUILDFOLDER/seafile-server/seafile-$VERSION_SEAFILE.tar.gz $PKGSOURCEDIR
  cp $BUILDFOLDER/seahub/seahub-$VERSION_SEAFILE.tar.gz $PKGSOURCEDIR
  cp $BUILDFOLDER/seafobj/seafobj.tar.gz $PKGSOURCEDIR
  cp $BUILDFOLDER/seafdav/seafdav.tar.gz $PKGSOURCEDIR
}

#
# Build server
#

build_server()
{
  echo
  echo -e "\e[93m-> [10/$STEPS] Build server\e[39m"

  mkdir -p $PKGDIR
  $SCRIPTPATH/$BUILDFOLDER/seafile-server/scripts/build/build-server.py \
    --libsearpc_version=$LIBSEARPC_VERSION \
    --ccnet_version=$VERSION_CCNET \
    --seafile_version=$VERSION_SEAFILE \
    --version=$VERSION \
    --thirdpartdir=$THIRDPARTYFOLDER \
    --srcdir=$SCRIPTPATH/$PKGSOURCEDIR \
    --outputdir=$SCRIPTPATH/$PKGDIR
}

#
# COMPLETE
#

echo_complete()
{
  echo
  echo -e "\e[93m-> BUILD COMPLETED.\e[39m"
}

#
# MAIN
#

install_dependencies
build_libevhtp

export_python_path

build_libsearpc
build_ccnet
build_seafile
build_seahub
build_seafobj
build_seafdav

copy_pkg_source
build_server
echo_complete
