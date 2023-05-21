#!/bin/bash

VERSION="${1}"
LIBSEARPC_VERSION_LATEST="3.3-latest" # check if new tag is available on https://github.com/haiwen/libsearpc/releases
LIBSEARPC_VERSION_FIXED="3.1.0" # libsearpc sticks to 3.1.0 https://github.com/haiwen/libsearpc/commit/43d768cf2eea6afc6e324c2b1a37a69cd52740e3

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
#"
BUILDFOLDER="haiwen-build"
BUILDPATH="${SCRIPTPATH}/${BUILDFOLDER}"
THIRDPARTYFOLDER="${BUILDPATH}/seahub_thirdparty"
PKGSOURCEDIR="built-seafile-sources"
PKGDIR="built-seafile-server-pkgs"
PREFIX="${HOME}/opt/local"
# Temporary folder for seafile-server dependency builds for shared libraries (ld)
# see https://github.com/haiwen/seahub/blob/eab3ba2f6d3a311728130d8752c716e782b8d62e/scripts/build/build-server.py#L324

VERSION_SEAFILE="6.0.1" # dummy version for seafile (see configure.ac)
MYSQL_CONFIG_PATH="/usr/bin/mysql_config" # ensure compilation with mysql support

VERSION_TAG="v${VERSION}-server"
LIBSEARPC_TAG="v${LIBSEARPC_VERSION_LATEST}"

# colors used in functions for better readability
TXT_YELLOW="\033[93m"
TXT_DGRAY="\033[1;30m"
TXT_LGRAY="\033[0;37m"
TXT_LRED="\033[1;31m"
TXT_RED="\033[0;31m"
TXT_BLUE="\033[0;34m"
TXT_GREEN="\033[0;32m"
TXT_BOLD="\033[1m"
TXT_ITALIC="\033[3m"
TXT_UNDERSCORE="\033[4m"
# 48;5 for background, 38;5 for foreground
TXT_GREEN_ON_GREY="\033[48;5;240;38;5;040m"
TXT_ORANGE_ON_GREY="\033[48;5;240;38;5;202m"
OFF="\033[0m"

msg()
{
  echo -e "\n${TXT_YELLOW}$1${OFF}\n"
}

error()
{
    echo -e "${TXT_LRED}error:${OFF} $1";
    exit 1
}

alldone()
{
    echo -e " ${TXT_GREEN}done! ${OFF}"
}

mkmissingdir()
{
    if [ ! -d "${1}" ]; then
        echo -en "create missing directory ${TXT_BLUE}$1${OFF}...";
        mkdir -p "${1}" || error "failed!";
        alldone;
    fi
}

exitonfailure()
{
  if [ $? -ne 0 ]; then
    error "$1"
  fi
}



#############################################

mkmissingdir "${BUILDPATH}"

msg "Build seafile-rpi ${VERSION_TAG}"

msg "-> [] Prepare build"
mkmissingdir "${PREFIX}"
msg "   Export LIBRARY_PATH, LD_LIBRARY_PATH, CPATH"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CPATH="${PREFIX}/include"
msg "   LIBRARY_PATH = ${LIBRARY_PATH} "
msg "   LD_LIBRARY_PATH = ${LD_LIBRARY_PATH} "
msg "   CPATH = ${CPATH} "

msg "-> [] Prepare libs"
# Export PKG_CONFIG_PATH for seafile-server and libsearpc
msg "   Export PKG_CONFIG_PATH for seafile-server and libsearpc"
export PKG_CONFIG_PATH="${BUILDPATH}/libsearpc:${PKG_CONFIG_PATH}"
export PKG_CONFIG_PATH="${BUILDPATH}/seafile-server/lib:${PKG_CONFIG_PATH}"
msg "   PKG_CONFIG_PATH = ${PKG_CONFIG_PATH} "

msg "-> [] Build libevhtp"
cd "${BUILDPATH}"
(set -x; git clone "https://www.github.com/haiwen/libevhtp.git")
cd libevhtp
(set -x; cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DEVHTP_DISABLE_SSL=ON -DEVHTP_BUILD_SHARED=OFF .)
(set -x; make)
(set -x; make install)
exitonfailure "Build libevhtp failed"

msg "-> [] Build libsearpc"
cd "${BUILDPATH}"
(set -x; git clone "https://github.com/haiwen/libsearpc.git")
cd libsearpc
(set -x; git reset --hard "${LIBSEARPC_TAG}")
(set -x; ./autogen.sh)
(set -x; ./configure)
(set -x; make dist)
exitonfailure "Build libsearpc failed"

msg "-> [] Build seafile-server (c_fileserver)"
cd "${BUILDPATH}"
(set -x; git clone "https://github.com/haiwen/seafile-server.git")
cd seafile-server
(set -x; git reset --hard "${VERSION_TAG}")
(set -x; ./autogen.sh)
(set -x; ./configure --with-mysql=${MYSQL_CONFIG_PATH} --enable-ldap)
(set -x; make dist)
exitonfailure "Build seafile-server failed"

if [ -d "${BUILDPATH}/seafile-server/fileserver" ];then
   msg "-> [] Build seafile-server (go_fileserver)"
   cd "${BUILDPATH}"
   cd seafile-server
   (set -x; git reset --hard "${VERSION_TAG}")
   (set -x; cd fileserver && CGO_ENABLED=0 go build .)
   exitonfailure "Build seafile-server (go_fileserver) failed"
fi

if [ -d "${BUILDPATH}/seafile-server/notification-server" ];then
  msg "-> [] Build seafile-server (notification_server)"
  cd "${BUILDPATH}"
  cd seafile-server
  (set -x; git reset --hard "${VERSION_TAG}")
  (set -x; cd notification-server && CGO_ENABLED=0 go build .)
  exitonfailure "Build seafile-server (notification_server) failed"
fi

msg "-> [] Build seahub"
cd "${BUILDPATH}"
(set -x; git clone "https://github.com/haiwen/seahub.git")
cd seahub
(set -x; git reset --hard "${VERSION_TAG}")
msg "   Export THIRDPARTYFOLDER to PATH"
export PATH="${THIRDPARTYFOLDER}:${PATH}"
msg "   PATH = ${PATH}"
msg "   Export THIRDPARTYFOLDER to PYTHONPATH"
export PYTHONPATH="${THIRDPARTYFOLDER}"
msg "   PYTHONPATH = $PYTHONPATH${OFF}"
# to fix [ERROR] django-admin scripts not found in PATH
msg "   export THIRDPARTYFOLDER/django/bin to PATH"
export PATH="${THIRDPARTYFOLDER}/django/bin:${PATH}"
msg "   PATH = ${PATH}"
(set -x; python3 -m pip install -r "${BUILDPATH}/seahub/requirements.txt" --target "${THIRDPARTYFOLDER}" --no-cache --upgrade --no-deps)
# generate package
# if python != python3.6 we need to "sudo ln -s /usr/bin/python3.6 /usr/bin/python" or with "pyenv global 3.6.9"
(set -x; python3 "${BUILDPATH}/seahub/tools/gen-tarball.py" --version="${VERSION_SEAFILE}" --branch=HEAD)
exitonfailure "Build seahub failed"

msg "-> [] Build seafobj"
cd "${BUILDPATH}"
(set -x; git clone "https://github.com/haiwen/seafobj.git")
cd seafobj
(set -x; git reset --hard "${VERSION_TAG}")
(set -x; make dist)
exitonfailure "Build seafobj failed"

msg "-> [] Build seafdav"
cd "${BUILDPATH}"
(set -x; git clone "https://github.com/haiwen/seafdav.git")
cd seafdav
(set -x; git reset --hard "${VERSION_TAG}")
(set -x; make)
exitonfailure "Build seafdav failed"

msg "-> [] Copy sources to ${PKGSOURCEDIR}/R${VERSION} "
mkmissingdir "${SCRIPTPATH}/${PKGSOURCEDIR}/R${VERSION}"
for i in \
  "${BUILDPATH}/libsearpc/libsearpc-${LIBSEARPC_VERSION_FIXED}.tar.gz" \
  "${BUILDPATH}/seafile-server/seafile-${VERSION_SEAFILE}.tar.gz" \
  "${BUILDPATH}/seafile-server/fileserver/fileserver" \
  "${BUILDPATH}/seafile-server/notification-server/notification-server" \
  "${BUILDPATH}/seahub/seahub-${VERSION_SEAFILE}.tar.gz" \
  "${BUILDPATH}/seafobj/seafobj.tar.gz" \
  "${BUILDPATH}/seafdav/seafdav.tar.gz"
do
  [ -f "$i" ] && (set -x; cp "$i" "${SCRIPTPATH}/${PKGSOURCEDIR}/R${VERSION}")
done

msg "-> [${STEPCOUNTER}/${STEPS}] Build Seafile server"
cd "${BUILDPATH}"
mkmissingdir "${SCRIPTPATH}/${PKGDIR}"

msg "-> Executing build-server.py"
if [ -f "${BUILDPATH}/seahub/scripts/build/build-server.py" ]; then
  (set -x; python3 "${BUILDPATH}/seahub/scripts/build/build-server.py" \
      --libsearpc_version="${LIBSEARPC_VERSION_FIXED}" \
      --seafile_version="${VERSION_SEAFILE}" \
      --version="${VERSION}" \
      --thirdpartdir="${THIRDPARTYFOLDER}" \
      --srcdir="${SCRIPTPATH}/${PKGSOURCEDIR}/R${VERSION}" \
      --mysql_config="${MYSQL_CONFIG_PATH}" \
      --outputdir="${SCRIPTPATH}/${PKGDIR}" \
      --yes)
else
  (set -x; python3 "${BUILDPATH}/seafile-server/scripts/build/build-server.py" \
      --libsearpc_version="${LIBSEARPC_VERSION_FIXED}" \
      --seafile_version="${VERSION_SEAFILE}" \
      --version="${VERSION}" \
      --thirdpartdir="${THIRDPARTYFOLDER}" \
      --srcdir="${SCRIPTPATH}/${PKGSOURCEDIR}/R${VERSION}" \
      --mysql_config="${MYSQL_CONFIG_PATH}" \
      --outputdir="${SCRIPTPATH}/${PKGDIR}" \
      --yes)
fi
exitonfailure "Build Seafile server failed"

msg "-> BUILD COMPLETED."
