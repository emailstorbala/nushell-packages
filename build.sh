#!/bin/bash
set -e

# delete any existing packages
echo "deleting existing packages if any..."
rm -f *.rpm *.deb

for release in {39..40}; do
  docker run --rm -it -v $(pwd):/code fedora:${release} /code/create_nushell_package.sh
done

for release in {8..9}; do
  docker run --rm -it -v $(pwd):/code rockylinux/rockylinux:${release} /code/create_nushell_package.sh
done

for release in "bookworm" "trixie"; do
  docker run --rm -it -v $(pwd):/code debian:${release} /code/create_nushell_package.sh
done
