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
# rpm-build     - provides tools required to generate rpm
# rust          - rust lang
# cargo         - package manager for rust
# openssl-devel - you know what this is

dnf install -y wget rubygems ruby-devel rpm-build rust cargo openssl-devel

# install fpm which is used to generate the rpm
gem install fpm

# install latest version of nu using cargo
cargo install nu

# strip the binary
strip ~/.cargo/bin/nu

# get the fedora release number
platform=$(cat /etc/os-release | grep VERSION_ID | cut -d "=" -f2)

# run the rpm generation script with the installed version of nu
nu create_nushell_package.nu "fc${platform}" "rpm"

