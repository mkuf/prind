#!/bin/bash

set -e

registry=${1}
platform="linux/amd64,linux/arm/v7"

for file in $(find . -iname *Dockerfile* -type f); do
  name=$(echo -n ${file} | rev | cut -f2 -d'/' | rev)
  context=$(echo -n ${file} | rev | cut -f2- -d'/' | rev)
  repo=$(grep "ARG REPO" ${file} | sed -r 's/.*REPO=(.*)$/\1/g')

  ## Only, if Dockerfile contains a repo
  if ! [ -z "${repo}" ]; then
    ref=$(git ls-remote ${repo} HEAD | cut -f1)
    sref=$(echo -n ${ref} | cut -c 1-7)

    ## Explicitly build Targets, except 'build'
    for target in $(grep "FROM .* as" ${file} | sed -r 's/.*FROM.*as (.*)/\1/g' | grep -v build); do

      ## Append Target to Tag unless it is 'run'
      if [ "${target}" != "run" ]; then
        tag_extra="-${target}"
      fi

      ## Nightly
      docker manifest inspect ${registry}${name}:${sref}${tag_extra} > /dev/null \
      || docker buildx build --build-arg VERSION=${ref} --platform ${platform} -t ${registry}${name}:${sref}${tag_extra} -t ${registry}${name}:nightly${tag_extra} --target ${target} --push ${context}

      ## Tags
      for tag in $(git ls-remote --tags --refs ${repo} | tail -n3 | rev | cut -f1 -d'/' | rev); do
        docker manifest inspect ${registry}${name}:${tag}${tag_extra} > /dev/null \
        || docker buildx build --build-arg VERSION=${tag} --platform ${platform} -t ${registry}${name}:${tag}${tag_extra} --target ${target} --push ${context}
      done

      unset tag_extra
    done
  fi
done
