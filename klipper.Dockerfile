FROM python:2 as base

ARG REPO=https://github.com/Klipper3d/klipper
ARG VERSION=master

WORKDIR /opt

## Download Klipper
RUN git clone ${REPO} klipper \
 && cd klipper \
 && git checkout ${VERSION}

## Install klipper requirements
RUN pip install -r klipper/scripts/klippy-requirements.txt

## Compile Python code
RUN python klipper/klippy/chelper/__init__.py

## Create Directories
RUN mkdir run cfg gcode

## User & Permissions
RUN groupadd klipper --gid 1000 \
 && useradd klipper --uid 1000 --gid klipper \
 && usermod klipper --append --groups dialout \
 && chown -R klipper:klipper klipper run cfg gcode

## --- Targets ---

## Start Klippy
FROM base as klippy
USER klipper
ENTRYPOINT ["python"]
CMD ["klipper/klippy/klippy.py", "-I", "run/klipper.tty", "-a", "run/klipper.sock", "cfg/printer.cfg"]

## For building MCU Code
FROM base as build
RUN apt update \
 && apt install build-essential libncurses-dev libnewlib-arm-none-eabi gcc-arm-none-eabi binutils-arm-none-eabi
