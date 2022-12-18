#!/bin/bash

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

function log {
  echo -e "\033[0;36m\n## ${1} \033[0m"
}

(
  log "System Info"
  docker system info

  log "Compose Version"
  docker compose version

  log "System df"
  docker system df

  log "Docker Images"
  docker image ls

  log "Disk Space"
  df -h

  log "Connected devices"
  ls -l /dev

  log "Image Versions of running containers"
  for container in $(docker ps -aqf "label=org.prind.service"); do
    echo "$(docker inspect --format '{{ index .Config.Labels "org.prind.service" }}' ${container}): $(docker inspect --format '{{ index .Config.Image }}' ${container}) $(docker inspect --format '{{ index .Config.Labels "org.prind.image.version"}}' ${container})"
  done

  log "All Containers"
  docker ps -af "label=org.prind.service"
) | tee ${tmpdir}/runtime-info.txt

log "Retrieving Klipper/Moonraker Logfiles"
docker cp $(docker ps -aqf "label=org.prind.service=klipper"):/opt/printer_data/logs ${tmpdir}

log "Copying current configs"
cp -a $(pwd) $tmpdir

log "Generating Archive"
tar --exclude-vcs -cvf prind-info-$(date +%d%m%Y-%H%M%S).tar.gz ${tmpdir}