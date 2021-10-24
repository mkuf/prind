#!/bin/bash

set -e

user=mkuf
platform="linux/amd64,linux/arm/v7"

for file in $(find . -iname *Dockerfile* -type f); do
  name=$(echo -n ${file} | rev | cut -f2 -d'/' | rev)
  context=$(echo -n ${file} | rev | cut -f2- -d'/' | rev)
  repo=$(grep "ARG REPO" ${file} | sed -r 's/.*REPO=(.*)$/\1/g')

  ## Only, if Dockerfile contains a repo
  if ! [ -z "${repo}" ]; then
    ref=$(git ls-remote ${repo} HEAD | cut -f1)
    sref=$(echo -n ${ref} | cut -c 1-7)

    ## Nightly
    docker manifest inspect ${user}/${name}:${sref} > /dev/null \
    || docker buildx build --build-arg VERSION=${ref} --platform ${platform} -t ${user}/${name}:${sref} -t ${user}/${name}:nightly --push ${context}

    ## Tags
    for tag in $(git ls-remote --tags --refs ${repo} | tail -n10 | rev | cut -f1 -d'/' | rev); do
      docker manifest inspect ${user}/${name}:${tag} > /dev/null \
      || docker buildx build --build-arg VERSION=${tag} --platform ${platform} -t ${user}/${name}:${tag} --push ${context}
    done
  fi
done
