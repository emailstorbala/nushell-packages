#!/bin/bash
set -e

# delete any existing rpms
rm -f nushell-*.rpm

for release in {38..40}; do
  docker run --rm -it -v $(pwd):/code fedora:${release} /code/fedora.sh
done

