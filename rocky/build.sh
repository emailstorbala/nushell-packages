#!/bin/bash
# mount the directory with create_nushell_package.nu script into /code
# when starting the docker container

set -e

cd /code

# cargo places built binaries at $HOME/.cargo/bin.
# add the location to PATH env variable
export PATH=$HOME/.cargo/bin:$PATH

# wget          - to fetch license and other details
# rubygems      - provides the gem command used to install fpm
# ruby-devel    - ruby headers when required to compile ruby gems
# rpm-build     - provides tools required to generate rpm
# openssl-devel - you know what this is
# make          - to run make targets
# gcc           - gnu compiler

dnf install -y wget rubygems ruby-devel rpm-build openssl-devel make gcc

# install fpm which is used to generate the rpm
gem install --file /code/rocky/Gemfile --no-lock

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

# get the fedora release number
platform=$(cat /etc/os-release | grep PLATFORM_ID | cut -d "=" -f2 | cut -d ":" -f2)

# run the rpm generation script with the installed version of nu
nu create_nushell_package.nu "${platform:0:3}" "rpm"

