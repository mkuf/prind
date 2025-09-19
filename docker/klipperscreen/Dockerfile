FROM python:3.13-trixie AS build

ARG REPO=https://github.com/KlipperScreen/KlipperScreen
ARG VERSION=master

RUN apt update \
 && apt install -y \
      libgirepository1.0-dev \
      libdbus-glib-1-dev \
      cmake \
      libsystemd-dev \
 && apt clean

WORKDIR /opt
RUN git clone ${REPO} klipperscreen \
 && cd klipperscreen \
 && git checkout ${VERSION}

RUN python -m venv venv \
 && venv/bin/pip install -r klipperscreen/scripts/KlipperScreen-requirements.txt

FROM python:3.13-slim-trixie AS run

RUN apt update \
 && apt install -y \
      git \
      xdotool \
      x11-xserver-utils \
      libglib2.0-0t64 \
      libgirepository-1.0-1 \
      gir1.2-gtk-3.0 \
      libopenjp2-7 \
      fonts-freefont-ttf \
      libcairo2 \
      libatlas3-base \
      libdbus-glib-1-2 \
 && apt clean

WORKDIR /opt
COPY --from=build /opt/klipperscreen ./klipperscreen
COPY --from=build /opt/venv ./venv

## Start klipperscreen
ENV XAUTHORITY=/tmp/.Xauthority
ENV DISPLAY=:0
VOLUME ["/opt/cfg"]
ENTRYPOINT ["/opt/venv/bin/python", "klipperscreen/screen.py"]
CMD ["-c", "cfg/klipperscreen.conf"]
