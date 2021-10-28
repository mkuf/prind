#!/bin/bash

set -e

registry=${1}
app=${2}

platform="linux/amd64,linux/arm/v7"
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
  docker manifest inspect ${registry}${app}:${shortref}${tag_extra} > /dev/null \
  || docker buildx build --build-arg VERSION=${ref} --platform ${platform} -t ${registry}${app}:${shortref}${tag_extra} -t ${registry}${app}:nightly${tag_extra} --target ${target} --push ${context}

  ## Tags
  for tag in $(git ls-remote --tags --sort='version:refname' --refs ${source} | tail -n3 | rev | cut -f1 -d'/' | rev); do
    docker manifest inspect ${registry}${app}:${tag}${tag_extra} > /dev/null \
    || docker buildx build --build-arg VERSION=${tag} --platform ${platform} -t ${registry}${app}:${tag}${tag_extra} --target ${target} --push ${context}
  done

  unset tag_extra
done
