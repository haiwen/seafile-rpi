#!/bin/bash

# Set the version which needs to be build
VERSION=${1:-'9.0.9'}

echo "Get the current build script"
wget -O build.sh https://raw.githubusercontent.com/haiwen/seafile-rpi/master/build.sh
chmod u+x build.sh

# Set the arch name for the armhf distros
sysArch=$(arch)
[ "$sysArch" == "aarch64" ] && archhfName='armv8l' || archhfName='armv7l'

declare -A lxcDistroMap=(["bullseye"]="debian/11/" ["buster"]="debian/10/" ["stretch"]="debian/9/" ["kinetic"]="ubuntu/22.10/" ["jammy"]="ubuntu/22.04/" ["focal"]="ubuntu/20.04/" ["bionic"]="ubuntu/18.04/")

# Assign the distros which need to be build
configLxcDistros=("jammy" "focal" "bionic" "bullseye" "buster")
configLxcArchs=("armhf")
if [[ "$sysArch" == "aarch64" ]]; then
  # Only add arm64 if system supports it
  configLxcArchs+=("arm64")
fi

lxcContainers=()
for lxcArch in ${configLxcArchs[@]}; do
  for lxcDistro in ${configLxcDistros[@]}; do
    lxcContainers+=("${lxcDistro}-${lxcArch}")
  done
done

echo "Building following distributions and architectures: "
echo ${lxcContainers[@]}

# Execute the builds
for container in ${lxcContainers[@]}; do
  archShort=${container#*-}
  distroName=${container%-*}
  [ "$archShort" == "arm64" ] && architecture='aarch64' || architecture=$archhfName
  echo -e "\n######################################################\n"
  echo "Distribution: $distroName"
  echo "Architecture: $architecture"

  exists=false
  {
    sudo lxc info $container &&
      exists=true
  }
  if $exists; then
    echo "Starting existing Lxc image $container"
    sudo lxc start $container
  else
    echo "Launching Lxc images:${lxcDistroMap[$distroName]}$archShort $container"
    sudo lxc launch images:"${lxcDistroMap[$distroName]}"$archShort $container

    # Add 'seafile' as super user
    sudo lxc exec $container -- apt install sudo
    sudo lxc exec $container -- useradd -m -s /bin/bash seafile
    sudo lxc exec $container -- /bin/bash -c "echo 'seafile ALL=(ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo"
  fi

  echo "Upgrade container packages: $container"
  sudo lxc exec $container -- apt-get update && apt-get -y upgrade

  echo "Building for container: $container"
  sudo lxc file push build.sh $container/home/seafile/

  echo "Execute build.sh for $container"
  while [ "$(sudo lxc exec ${container} -- bash -c 'hostname -I' 2>/dev/null)" = "" ]; do
      echo -e "\e[1A\e[KNo network available in $container: $(date)"
      sleep .5
  done
  echo -e "\e[1A\e[KNetwork available in $container";
  sudo lxc exec $container -- su - seafile -- ./build.sh -DTA -v $VERSION -h https://raw.githubusercontent.com/haiwen/seafile-rpi/master/requirements/seahub_requirements_v${VERSION}.txt -d https://raw.githubusercontent.com/haiwen/seafile-rpi/master/requirements/seafdav_requirements_v${VERSION}.txt
  filename=$(sudo lxc exec $container -- bash -c "ls /home/seafile/built-seafile-server-pkgs/seafile-server-$VERSION-*.tar.gz" 2>/dev/null)
  sudo lxc file pull "$container$filename" ./

  echo -e "Build finished for container $container\n\n"
  sudo lxc stop $container
done

echo "Building distros finished"
