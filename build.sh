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
# Lets get the list of recent docker image tags against fedora.
# ignore latest & rawhide tags
# Sort the remaining tags in descending order
# now first tag is equivalent to rawhide, so lets ignore.
# second tag is the current latest release.
# third tag is the oldest supported release.
# ignore the rest of the tags as they are EOL releases.
# lets take the second and third item.
releases=$(curl -s https://hub.docker.com/v2/namespaces/library/repositories/fedora/tags?page_size=10 | jq ".results[].name" | sort -ru | grep -Ev "latest|rawhide" | head -n 3 | tail -n 2)
for release in $releases; do
  tag=$(echo $release | sed -e 's/"//g')
  docker run --rm -it -v $(pwd):/code fedora:${tag} /code/create_nushell_package.sh
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

# Create a github release to upload the packages to.
gh_release_id=$(curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GH_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d "{\"tag_name\":\"${TAG}\",\"target_commitish\":\"main\",\"name\":\"Release ${NU_SHELL_VERSION}\",\"draft\":false,\"prerelease\":false}" \
  https://api.github.com/repos/emailstorbala/nushell-packages/releases | jq '.id')

# # Search release by tag name
# gh_release_id=$(curl -L \
#   -H "Accept: application/vnd.github+json" \
#   -H "Authorization: Bearer ${GH_TOKEN}" \
#   -H "X-GitHub-Api-Version: 2022-11-28" \
#   https://api.github.com/repos/emailstorbala/nushell-packages/releases/tags/${TAG} | jq '.id')

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
  # print a new line to seperate the curl output and next line
  echo ""
done
