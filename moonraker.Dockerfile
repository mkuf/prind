FROM python:3

ARG REPO=https://github.com/Arksine/moonraker
ARG VERSION=master

WORKDIR /opt

## Install Requirements
RUN apt update \
 && apt install -y \
      libopenjp2-7 \
      python3-libgpiod \
      curl \
      libcurl4-openssl-dev \
      libssl-dev \
      liblmdb0 \
      libsodium-dev \
      zlib1g-dev

## Download moonraker
RUN git clone ${REPO} moonraker \
 && cd moonraker \
 && git checkout ${VERSION}

## Setup Python
RUN pip install -r moonraker/scripts/moonraker-requirements.txt

## Create Direcories
RUN mkdir run cfg gcode db

## User & Permissions
RUN groupadd moonraker --gid 1000 \
 && useradd moonraker --uid 1000 --gid moonraker \
 && usermod moonraker --append --groups dialout \
 && chown -R moonraker:moonraker moonraker run cfg gcode db

## Start Klippy
USER moonraker
ENTRYPOINT ["python"]
CMD ["moonraker/moonraker/moonraker.py", "-c", "cfg/moonraker.cfg"]

