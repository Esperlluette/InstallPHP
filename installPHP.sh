#!/bin/bash

version=$1

if [[ ! $1 =~ ^[0-9].[0-9]$ ]]; then
    echo "Error, the version ${version} is invalid."
    exit 125
fi

PRE_INSTALL_PKGS=""

if [ ! -e /usr/lib/apt/methods/https ]; then
   PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} apt-transport-https"
fi

if [ ! -x /usr/bin/lsb_release ]; then
    PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} lsb-release"
fi

if [ ! -x /usr/bin/curl ]; then
    PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} curl"
fi

if [ ! -x /usr/bin/gpg ]; then
    PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} gnupg"
fi

apt-get update

if [ "X${PRE_INSTALL_PKGS}" != "X" ]; then
    echo "Installing required packages: ${PRE_INSTALL_PKGS}"
    
    apt-get install -y ${PRE_INSTALL_PKGS}

    echo "Done."
fi

if [ ! -f /etc/apt/sources.list.d/sury-php.list ]; then
  echo "Adding php sury repository..."

  keyring='/usr/share/keyrings'
  key_url="https://packages.sury.org/php/apt.gpg"
  local_key="$keyring/sury-php.gpg"
  curl -s $key_url | gpg --dearmor | tee $local_key > /dev/null

  echo "deb [signed-by=${local_key}] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/sury-php.list

  echo "Done."
fi

apt-get update

apt-get install -y php${version} php${version}-curl php${version}-xml php${version}-zip php${version}-mbstring php${version}-mysql php${version}-opcache php${version}-xdebug php${version}-intl php${version}-apcu php${version}-gd
