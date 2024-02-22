#!/bin/bash

## Setup for building multiplatform images
##
## apt install qemu-user-static
## docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
## docker buildx create --use --name cross
## docker buildx inspect --bootstrap
## docker buildx build --platform linux/amd64,linux/arm/v7 -t octoprint:latest --target run .

set -e

app=${1}
registry=${2}

# Set build parameters
platform="linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8"
dockerfile=docker/${app}/Dockerfile
context=$(echo -n ${dockerfile} | rev | cut -f2- -d'/' | rev)

# Get get versioning info from upstream repo
## Set up directories
pwd=$(pwd)
tmp=$(mktemp -d)
## Get upstream repo from Dockerfile
source=$(grep "ARG REPO" ${dockerfile} | sed -r 's/.*REPO=(.*)$/\1/g')
## Clone repo
git clone ${source} ${tmp} > /dev/null
## enter repo directory and get infos
cd ${tmp}
upstream_version=$(git describe --tags)
upstream_tags=($(git tag -l --sort='v:refname' | tail -n3))
upstream_sha=$(git rev-parse HEAD)
## Return to previous directory and remove tmp
cd ${pwd}
rm -rf ${tmp}

# Set label Values
label_date=$(date --rfc-3339=seconds)
label_prind_version=$(git describe --tags)
if [ "${CI}" == "true" ]; then
  label_author="${GITHUB_REPOSITORY_OWNER}"
  label_url="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}"
  label_doc="${label_url}/blob/${GITHUB_SHA}/docker/${app}/README.md"
  label_src="${label_url}/blob/${GITHUB_SHA}/docker/${app}"
else
  label_author="$(whoami)"
  label_url="local"
  label_doc="local"
  label_src="local"
fi

# Colorful output
function log {
  echo -e "\033[0;36m## ${1} \033[0m"
}

## Explicitly build Targets, except 'build'
for target in $(grep "FROM .* as" ${dockerfile} | sed -r 's/.*FROM.*as (.*)/\1/g' | grep -v build); do

  ## Append Target to Tag unless it is 'run'
  if [ "${target}" != "run" ]; then
    tag_extra="-${target}"
  fi

  ## latest
  if docker buildx imagetools inspect ${registry}${app}:${upstream_version}${tag_extra} > /dev/null; then
    log "## Image ${registry}${app}:${upstream_version}${tag_extra} already exists, nothing to do."
  else
    log "## Building latest Image ${registry}${app}:${upstream_version}${tag_extra}"
    docker buildx build \
      --build-arg VERSION=${upstream_sha} \
      --platform ${platform} \
      --tag ${registry}${app}:${upstream_version}${tag_extra} \
      --tag ${registry}${app}:latest${tag_extra} \
      --label org.prind.version=${label_prind_version} \
      --label org.prind.image.created="${label_date}" \
      --label org.prind.image.authors="${label_author}" \
      --label org.prind.image.url="${label_url}" \
      --label org.prind.image.documentation="${label_doc}" \
      --label org.prind.image.source="${label_src}" \
      --label org.prind.image.version="${upstream_version}" \
      --label org.prind.image.sha="${upstream_sha}" \
      --target ${target} \
      --push \
      ${context}
  fi

  ## Tags
  for tag in ${upstream_tags[@]}; do
    if docker buildx imagetools inspect ${registry}${app}:${tag}${tag_extra} > /dev/null; then
      log "## Image ${registry}${app}:${tag}${tag_extra} already exists, nothing to do."
    else
      log "## Building Image for tagged release ${registry}${app}:${tag}${tag_extra}"
      docker buildx build \
        --build-arg VERSION=${tag} \
        --platform ${platform} \
        --tag ${registry}${app}:${tag}${tag_extra} \
        --label org.prind.version=${label_prind_version} \
        --label org.prind.image.created="${label_date}" \
        --label org.prind.image.authors="${label_author}" \
        --label org.prind.image.url="${label_url}" \
        --label org.prind.image.documentation="${label_doc}" \
        --label org.prind.image.source="${label_src}" \
        --label org.prind.image.version="${tag}" \
        --label org.prind.image.sha="${upstream_sha}" \
        --target ${target} \
        --push \
        ${context}
    fi
  done

  unset tag_extra
done
