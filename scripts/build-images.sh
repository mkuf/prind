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

platform="linux/amd64,linux/arm/v7,linux/arm64/v8"
dockerfile=docker/${app}/Dockerfile
context=$(echo -n ${dockerfile} | rev | cut -f2- -d'/' | rev)

source=$(grep "ARG REPO" ${dockerfile} | sed -r 's/.*REPO=(.*)$/\1/g')
ref=$(git ls-remote ${source} HEAD | cut -f1)
shortref=$(echo -n ${ref} | cut -c 1-7)

## Explicitly build Targets, except 'build'
for target in $(grep "FROM .* as" ${dockerfile} | sed -r 's/.*FROM.*as (.*)/\1/g' | grep -v build); do

  ## Append Target to Tag unless it is 'run'
  if [ "${target}" != "run" ]; then
    tag_extra="-${target}"
  fi

  ## Nightly
  if docker manifest inspect ${registry}${app}:${shortref}${tag_extra} > /dev/null; then
    echo -e "\033[0;36m## Image ${registry}${app}:${shortref}${tag_extra} already exists, nothing to do. \033[0m"
  else
    echo -e "\033[0;36m## Building nightly Image ${registry}${app}:${shortref}${tag_extra} \033[0m"
    docker buildx build --build-arg VERSION=${ref} --platform ${platform} -t ${registry}${app}:${shortref}${tag_extra} -t ${registry}${app}:nightly${tag_extra} --target ${target} --push ${context}
  fi

  ## Tags
  for tag in $(git ls-remote --tags --sort='version:refname' --refs ${source} | tail -n3 | rev | cut -f1 -d'/' | rev); do
    if docker manifest inspect ${registry}${app}:${tag}${tag_extra} > /dev/null; then
      echo -e "\033[0;36m## Image ${registry}${app}:${tag}${tag_extra} already exists, nothing to do. \033[0m"
    else
      echo -e "\033[0;36m## Building Image for tagged release ${registry}${app}:${tag}${tag_extra} \033[0m"
      docker buildx build --build-arg VERSION=${tag} --platform ${platform} -t ${registry}${app}:${tag}${tag_extra} --target ${target} --push ${context}
    fi
  done

  unset tag_extra
done
