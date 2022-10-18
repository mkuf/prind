## Get Code and Build venv
FROM python:2 as build

ARG REPO=https://github.com/Klipper3d/klipper
ARG VERSION=master

WORKDIR /opt

RUN git clone ${REPO} klipper \
 && cd klipper \
 && git checkout ${VERSION}

RUN virtualenv -p python2 venv \
 && venv/bin/pip install -r klipper/scripts/klippy-requirements.txt \
 && venv/bin/pip install numpy \
 && venv/bin/python -m compileall klipper/klippy \
 && venv/bin/python klipper/klippy/chelper/__init__.py

## Runtime Image
FROM python:2-slim as run

WORKDIR /opt
COPY --from=build /opt/klipper ./klipper
COPY --from=build /opt/venv ./venv

RUN mkdir printer_data
RUN groupadd klipper --gid 1000 \
 && useradd klipper --uid 1000 --gid klipper \
 && usermod klipper --append --groups dialout \
 && chown -R klipper:klipper /opt/*

USER klipper
VOLUME ["/opt/printer_data"]
ENTRYPOINT ["/opt/venv/bin/python", "klipper/klippy/klippy.py"]
CMD ["-I", "printer_data/run/klipper.tty", "-a", "printer_data/run/klipper.sock", "printer_data/config/printer.cfg"]

## For building MCU Code
FROM ubuntu:18.04 as mcu

WORKDIR /opt
COPY --from=build /opt/klipper ./klipper
COPY --from=build /opt/venv ./venv

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update \
 && apt install -y \
      virtualenv python-dev libffi-dev build-essential \
      libncurses-dev \
      libusb-dev \
      avrdude gcc-avr binutils-avr avr-libc \
      stm32flash libnewlib-arm-none-eabi \
      gcc-arm-none-eabi binutils-arm-none-eabi libusb-1.0 \
      python3-numpy python3-matplotlib \
 && apt clean

## Build klipper.elf for Simulavr and Simulavr itself
FROM mcu as build-simulavr

RUN apt update \
 && apt install -y \
      git cmake swig \
      python3-dev \
 && apt clean

WORKDIR /opt/klipper
COPY config.simulavr .config
RUN make 

WORKDIR /opt
RUN git clone git://git.savannah.nongnu.org/simulavr.git \
 && cd simulavr \
 && git checkout release-1.1.0 \
 && make python \
 && make build

RUN mkdir run
RUN groupadd simulavr --gid 1000 \
 && useradd simulavr --uid 1000 --gid simulavr \
 && usermod simulavr --append --groups dialout \
 && chown -R simulavr:simulavr /opt/*

USER simulavr
ENV PYTHONPATH=/opt/simulavr/build/pysimulavr/
VOLUME ["/opt/run"]
ENTRYPOINT ["klipper/scripts/avrsim.py"]
CMD ["-p", "/opt/printer_data/run/simulavr.tty", "/opt/klipper/out/klipper.elf"]