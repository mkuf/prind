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

# Get latest commitref from upstream repo
source=$(grep "ARG REPO" ${dockerfile} | sed -r 's/.*REPO=(.*)$/\1/g')
ref=$(git ls-remote ${source} HEAD | cut -f1)
shortref=$(echo -n ${ref} | cut -c 1-7)

# Set label Values
label_date=$(date --rfc-3339=seconds)
if [ "${CI}" == "true" ]; then
  label_prind_version="${GITHUB_SHA}"
  label_author="${GITHUB_REPOSITORY_OWNER}"
  label_url="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}"
  label_doc="${label_url}/blob/${GITHUB_SHA}/docker/${app}/README.md"
  label_src="${label_url}/blob/${GITHUB_SHA}/docker/${app}"
else
  label_prind_version="$(git rev-parse HEAD)"
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
  if docker buildx imagetools inspect ${registry}${app}:${shortref}${tag_extra} > /dev/null; then
    log "## Image ${registry}${app}:${shortref}${tag_extra} already exists, nothing to do."
  else
    log "## Building latest Image ${registry}${app}:${shortref}${tag_extra}"
    docker buildx build \
      --build-arg VERSION=${ref} \
      --platform ${platform} \
      --tag ${registry}${app}:${shortref}${tag_extra} \
      --tag ${registry}${app}:latest${tag_extra} \
      --label org.prind.version=${label_prind_version} \
      --label org.prind.image.created="${label_date}" \
      --label org.prind.image.authors="${label_author}" \
      --label org.prind.image.url="${label_url}" \
      --label org.prind.image.documentation="${label_doc}" \
      --label org.prind.image.source="${label_src}" \
      --label org.prind.image.version="${ref}" \
      --target ${target} \
      --push \
      ${context}
  fi

  ## Tags
  for tag in $(git -c 'versionsort.suffix=-' ls-remote --tags --sort='version:refname' --refs ${source} | tail -n3 | rev | cut -f1 -d'/' | rev); do
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
        --target ${target} \
        --push \
        ${context}
    fi
  done

  unset tag_extra
done
