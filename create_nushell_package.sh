#!/bin/bash

set -e

# Lets create a workdir inside the container,
# so everything happens in isolation,
# and we can run multiple build in parallel
mkdir -p "${HOME}/nushell"

cp -a /code/. "${HOME}/nushell"

cd "${HOME}/nushell"


PLATFORM=$(grep "^ID=" /etc/os-release | cut -d "=" -f2)
PLATFORM=${PLATFORM//\"/}

# We need the following dependencies to package nushell
# nu shell cargo dependency
# openssl-devel
# libX11-devel
# libxcb

# needed by our create_nushell_package script
# wget          - to fetch license and other details

# needed to install fpm
# gcc           - gnu compiler
# make          - to run make targets
# rubygems      - provides the gem command used to install fpm
# ruby-devel    - ruby headers when required to compile ruby gems
# rpm-build     - provides tools required to generate rpm

# lets check for presence of /etc/redhat-release.
# If present it is either fedora / rockylinux
# else it is debian and derivates
if [ -f /etc/redhat-release ]; then
    dnf install -y wget rubygems ruby-devel rpm-build openssl-devel make gcc libxcb openssl-devel libX11-devel
else
    apt update
    apt install -y wget curl rubygems ruby-dev libssl-dev gcc pkg-config
fi

# installing fpm which is used to generate the different package types
if [ "$PLATFORM" = "rocky" ]; then
    ls -l "${HOME}/nushell"
    # rocky has a problem with one of the dependencies of fpm, which asks for ruby 3.0
    # so pinned deps
    gem install --file ${HOME}/nushell/fpm/Gemfile --no-lock
else
    gem install fpm
fi

# install latest rust & cargo via rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o "${HOME}/rustup-init.sh"

chmod +x /root/rustup-init.sh

/root/rustup-init.sh -y

# sourcing rust env
source "${HOME}/.cargo/env"

cargo install nu --locked

# strip the binary
strip ${HOME}/.cargo/bin/nu

# prepare for running the package generation script
if [ "$PLATFORM" = "rocky" ]; then
    RELEASE=$(grep PLATFORM_ID /etc/os-release | cut -d "\"" -f2 | cut -d ":" -f2)
    PKG_TYPE="rpm"
fi

if [ "$PLATFORM" = "fedora" ]; then
    RELEASE=$(grep VERSION_ID /etc/os-release | cut -d "=" -f2)
    RELEASE="fc${RELEASE}"
    PKG_TYPE="rpm"
fi

if [ "$PLATFORM" = "debian" ]; then
    RELEASE=$(grep VERSION_CODENAME /etc/os-release | grep VERSION_CODENAME | cut -d "=" -f2)
    PKG_TYPE="deb"
fi

# generate package
nu create_nushell_package.nu "${RELEASE}" "${PKG_TYPE}"

# copy the package to host filesystem.
cp ${HOME}/nushell/*.${PKG_TYPE} /code/
