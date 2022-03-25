## Get Code and Build venv
FROM python:3 as build

ARG REPO=https://github.com/Arksine/moonraker
ARG VERSION=master

WORKDIR /opt

RUN git clone ${REPO} moonraker \
 && cd moonraker \
 && git checkout ${VERSION}

RUN python -m venv venv \
 && venv/bin/pip install -r moonraker/scripts/moonraker-requirements.txt

## Runtime Image
FROM python:3-slim as run

RUN apt update \
 && apt install -y \
      libopenjp2-7 \
      python3-libgpiod \
      curl \
      libcurl4 \
      libssl1.1 \
      liblmdb0 \
      libsodium23 \
      libjpeg62-turbo \
      libtiff5 \
      libxcb1 \
      zlib1g \
      iproute2 \
      systemd \
      sudo \
 && apt clean

WORKDIR /opt
COPY --from=build /opt/moonraker ./moonraker
COPY --from=build /opt/venv ./venv

RUN mkdir run cfg gcode db log
RUN groupadd moonraker --gid 1000 \
 && useradd moonraker --uid 1000 --gid moonraker \
 && usermod moonraker --append --groups dialout \
 && chown -R moonraker:moonraker /opt/*

RUN ln -s /bin/systemctl /sbin/shutdown \
 && ln -s /bin/systemctl /sbin/reboot \
 && echo -n "moonraker ALL = NOPASSWD: /bin/systemctl, /sbin/shutdown, /sbin/reboot" > /etc/sudoers.d/moonraker

## Start Moonraker
USER moonraker
EXPOSE 7125
VOLUME ["/opt/run", "/opt/cfg", "/opt/gcode", "/opt/db"]
ENTRYPOINT ["/opt/venv/bin/python", "moonraker/moonraker/moonraker.py"]
CMD ["-c", "cfg/moonraker.cfg"]

