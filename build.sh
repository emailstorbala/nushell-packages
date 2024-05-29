#!/bin/bash
set -e

# delete any existing packages
echo "deleting existing rpm packages if any..."
rm -f nushell-*.rpm

echo "deleting existing deb packages if any..."
rm -f nushell_*.deb

for release in {39..41}; do
  docker run --rm -it -v $(pwd):/code fedora:${release} /code/fedora.sh
done

for release in {8..9}; do
  docker run --rm -it -v $(pwd):/code rockylinux/rockylinux:${release} /code/rocky/build.sh
done

for release in "bookworm" "trixie"; do
  docker run --rm -it -v $(pwd):/code debian:${release} /code/debian.sh
done
