#!/bin/bash
set -e

# this script assumes
# * you have docker, curl & jq installed and available in path.
# * github api token is configured in environment variable GH_TOKEN.
# * internet access is available to access nushell cargo installation.
# * a new gitlab release is created with tag in the format "vx.y.z" where x.y.z is the nu shell version.

if [ -z "${GH_TOKEN}" ]; then
    echo "GitHub authentication information is not set."
    exit 1
fi

# delete any existing packages
echo "deleting existing packages if any..."
rm -f *.rpm *.deb

# Fedora
for release in {39..40}; do
  docker run --rm -it -v $(pwd):/code fedora:${release} /code/create_nushell_package.sh
done

# RockyLinux
for release in {8..9}; do
  docker run --rm -it -v $(pwd):/code rockylinux/rockylinux:${release} /code/create_nushell_package.sh
done

# Debian
for release in "bookworm" "trixie"; do
  docker run --rm -it -v $(pwd):/code debian:${release} /code/create_nushell_package.sh
done

# NU_SHELL_VERSION=$(find . -maxdepth 1 -name "*fc*" | head -1 | cut -d '-' -f2)
NU_SHELL_VERSION=$(ls *fc* | head -1 | cut -d '-' -f2)
TAG="v${NU_SHELL_VERSION}"
gh_release_id=$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GH_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/emailstorbala/nushell-packages/releases/tags/${TAG} | jq '.id')

# upload the generated packages
for package in $(ls *.rpm *.deb); do
  echo "uploading ${package} to release ${gh_release_id} with tag ${TAG}"
  curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GH_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/octet-stream" \
  "https://uploads.github.com/repos/emailstorbala/nushell-packages/releases/${gh_release_id}/assets?name=${package}" \
  --data-binary "@${package}"
done
