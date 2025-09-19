## Get Code and Build venv
FROM python:3.12-trixie AS build

WORKDIR /opt
COPY requirements-prind.txt .

RUN python -m venv venv \
 && venv/bin/pip install -r requirements-prind.txt

ARG REPO=https://github.com/Arksine/moonraker
ARG VERSION=master

RUN git clone ${REPO} moonraker \
 && cd moonraker \
 && git checkout ${VERSION} \
 && echo -n $(git describe --tags)-prind > moonraker/.version \
 && rm -rf .git

RUN python -m venv venv \
 && venv/bin/pip install -r moonraker/scripts/moonraker-requirements.txt

## Runtime Image
FROM python:3.12-slim-trixie AS run

RUN apt update \
 && apt install -y \
      libopenjp2-7 \
      python3-libgpiod \
      curl \
      libcurl4t64 \
      libssl3t64 \
      liblmdb0 \
      libsodium23 \
      libjpeg62-turbo \
      libtiff6 \
      libxcb1 \
      zlib1g \
      iproute2 \
      systemd \
      sudo \
      git \
      jq \
 && apt clean

WORKDIR /opt
RUN groupadd moonraker --gid 1000 \
 && useradd moonraker --uid 1000 --gid moonraker \
 && usermod moonraker --append --groups dialout
RUN mkdir -p printer_data/run printer_data/gcodes printer_data/logs printer_data/database printer_data/config \
 && chown -R moonraker:moonraker /opt/*

COPY --chown=moonraker:moonraker health.sh ./

COPY --chown=moonraker:moonraker --from=build /opt/moonraker ./moonraker
COPY --chown=moonraker:moonraker --from=build /opt/venv ./venv

RUN ln -s /bin/systemctl /sbin/shutdown \
 && ln -s /bin/systemctl /sbin/reboot \
 && echo -n "moonraker ALL = NOPASSWD: /bin/systemctl, /sbin/shutdown, /sbin/reboot" > /etc/sudoers.d/moonraker

## Start Moonraker
USER moonraker
EXPOSE 7125
VOLUME ["/opt/printer_data/run", "/opt/printer_data/gcodes", "/opt/printer_data/logs", "/opt/printer_data/database", "/opt/printer_data/config"]
ENTRYPOINT ["/opt/venv/bin/python", "moonraker/moonraker/moonraker.py"]
CMD ["-d", "/opt/printer_data"]

