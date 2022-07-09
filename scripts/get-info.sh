#!/bin/bash

echo -e "
This Script will generate an archive containing the following data:
  - docker system info
  - docker compose version
  - Currently running containers of this stack
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

  log "Image Versions of running containers"
  for i in $(docker compose ps --services); do
    container=$(docker compose ps -q ${i})
    echo "${i}: $(docker inspect --format '{{ index .Config.Image }}' ${container}) $(docker inspect --format '{{ index .Config.Labels "org.prind.image.version"}}' ${container})"
  done

  log "Running Containers"
  docker compose ps
) | tee ${tmpdir}/runtime-info.txt

log "Retrieving Klipper/Moonraker Logfiles"
docker compose cp klipper:/opt/log ${tmpdir}

log "Copying current configs"
cp -a $(pwd) $tmpdir

log "Generating Archive"
tar --exclude-vcs -cvf prind-info-$(date +%d%m%Y-%H%M%S).tar.gz ${tmpdir}