#!/bin/bash
# mount the directory with create_nushell_package.nu script into /code
# when starting the docker container

set -e

cd /code

# cargo places built binaries at $HOME/.cargo/bin.
# add the location to PATH env variable
export PATH=$HOME/.cargo/bin:$PATH

apt update

# wget          - to fetch license and other details
# curl          - used to fetch rustup to install rust
# rubygems      - provides the gem command used to install fpm
# ruby-dev      - ruby headers when required to compile ruby gems
# libssl-dev    - you know what this is
# gcc           - gnu compiler
# pkg-config    - required by gem install fpm to use libssl-dev headers

apt  install -y wget curl rubygems ruby-dev libssl-dev gcc pkg-config

# install fpm which is used to generate the package
gem install fpm

# install latest rust & cargo via rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o "${HOME}/rustup-init.sh"
chmod +x /root/rustup-init.sh
/root/rustup-init.sh -y

# sourcing rust env
source "${HOME}/.cargo/env"

# install latest version of nu using cargo
cargo install nu

# strip the binary
strip ${HOME}/.cargo/bin/nu

# get the debian release code name
platform=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d "=" -f2)

# run the rpm generation script with the installed version of nu
nu create_nushell_package.nu "${platform}" "deb"

