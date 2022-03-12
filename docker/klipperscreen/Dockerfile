FROM python:3 as build

ARG REPO=https://github.com/jordanruthe/KlipperScreen
ARG VERSION=master

RUN apt update \
 && apt install -y \
      libgirepository1.0-dev \
 && apt clean

WORKDIR /opt
RUN git clone ${REPO} klipperscreen \
 && cd klipperscreen \
 && git checkout ${VERSION}

RUN python -m venv venv \
 && venv/bin/pip install -r klipperscreen/scripts/KlipperScreen-requirements.txt

FROM python:3-slim as run

RUN apt update \
 && apt install -y \
      libglib2.0-0 \
      libgirepository-1.0-1 \
      gir1.2-gtk-3.0 \
 && apt clean

WORKDIR /opt
COPY --from=build /opt/klipperscreen ./klipperscreen
COPY --from=build /opt/venv ./venv

RUN mkdir cfg
RUN groupadd klipperscreen --gid 1000 \
 && useradd klipperscreen --uid 1000 --gid klipperscreen \
 && chown -R klipperscreen:klipperscreen /opt/*

## Start klipperscreen
USER klipperscreen
ENV XAUTHORITY=/tmp/.Xauthority
ENV DISPLAY=:0
VOLUME ["/opt/cfg"]
ENTRYPOINT ["/opt/venv/bin/python", "klipperscreen/screen.py"]
CMD ["-c", "cfg/klipperscreen.conf"]