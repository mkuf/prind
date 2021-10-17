## Get Code and make
FROM debian:buster-slim as build

ARG REPO=https://github.com/pikvm/ustreamer
ARG VERSION=master

WORKDIR /opt

RUN apt update \
 && apt install -y \
      ca-certificates \
      make \
      gcc \
      git \
      libevent-dev \
      libjpeg62-turbo-dev \
      libbsd-dev \
      libgpiod-dev \
 && apt clean

RUN git clone ${REPO} ustreamer \
 && cd ustreamer \
 && git checkout ${VERSION}

RUN cd ustreamer \
 && make

## Runtime Image
FROM debian:buster-slim as run

RUN apt update \
 && apt install -y \
      ca-certificates \
      libevent-2.1 \
      libevent-pthreads-2.1-6 \
      libjpeg62-turbo \
      libbsd0 \
      libgpiod2 \
 && apt clean

WORKDIR /opt
COPY --from=build /opt/ustreamer ./ustreamer

RUN groupadd ustreamer --gid 1000 \
 && useradd ustreamer --uid 1000 --gid ustreamer \
 && usermod ustreamer --append --groups video \
 && chown -R ustreamer:ustreamer /opt/*

USER ustreamer
ENTRYPOINT [ "/opt/ustreamer/ustreamer", "--host=0.0.0.0", "--port=8080", "--slowdown", "--device=/dev/video0", "--resolution=1280x960", "--format=MJPEG", "--desired-fps=30"]
