#!/bin/bash

set -e

if ! [ -f "docker-compose.yaml" ]; then
  echo -e "
  \033[1;31mMissing docker-compose.yaml\033[0m

  You are currently in \033[0;36m$(pwd)\033[0m
  Run this script from the root of prind to gather all necessary data.
  >  cd prind
  >  ./scripts/get-info.sh
  "
  exit 1
fi

echo -e "
This Script will generate an archive containing the following data:
  - docker system info
  - docker compose version
  - docker system storage metrics
  - docker images available
  - host storage usage metrics
  - list of currently connected devices
  - Containers of this stack
  - Image Names and versions of currently running containers of this stack
  - klippy.log and moonraker.log
  - a full copy of this directory

\033[1;31mWarning!\033[0m
The generated files might contain sensitive data like api keys.
Be sure to remove all data you do not wish to share before uploading the archive to the issuetracker.
Press [Enter] to continue or [Ctrl+C] to abort.
"
read

tmpdir=$(mktemp -d --suffix=-prind)

function pad_cmd {
  echo "## ${@}"
  ${@}
  echo "## END ${@}"
  echo ""
}

commands=(
  "docker system info"
  "docker compose version"
  "docker system df"
  "docker image ls"
  "df -h"
  "ls -lRn /dev"
  "docker ps -af label=org.prind.service"
  "docker cp $(docker ps -aqf label=org.prind.service=klipper):/opt/printer_data/logs ${tmpdir}"
  "cp -a $(pwd) $tmpdir"
)

(
  for cmd in "${commands[@]}"; do
    pad_cmd ${cmd}
  done

  echo "## Image Versions"
  for container in $(docker ps -aqf "label=org.prind.service"); do
    echo "$(docker inspect --format '{{ index .Config.Labels "org.prind.service" }}' ${container}): $(docker inspect --format '{{ index .Config.Image }}' ${container}) $(docker inspect --format '{{ index .Config.Labels "org.prind.image.version"}}' ${container})"
  done
  echo "## END Image Versions"

) > ${tmpdir}/info.txt 2>&1

## Generate archive
archive_name="prind-info-$(date +%d%m%Y-%H%M%S).tar.gz"
tar -cf ${archive_name} ${tmpdir} 2> /dev/null

## Prompt user to upload the generated file
echo -e "
\033[1;32mSuccess:\033[0m Please attach \033[1;33m${archive_name}\033[0m to your issue.
"