## Get Code and make
FROM debian:trixie-slim AS build

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
      pkg-config \
 && apt clean

RUN git clone ${REPO} ustreamer \
 && cd ustreamer \
 && git checkout ${VERSION} \
 && rm -rf .git

RUN cd ustreamer \
 && make LDFLAGS=-latomic

## Runtime Image
FROM debian:trixie-slim AS run

RUN apt update \
 && apt install -y \
      ca-certificates \
      libevent-2.1-7t64 \
      libevent-pthreads-2.1-7t64 \
      libjpeg62-turbo \
      libbsd0 \
      libgpiod3 \
      v4l-utils \
      curl \
      jq \
 && apt clean

WORKDIR /opt
RUN groupadd ustreamer --gid 1000 \
 && useradd ustreamer --uid 1000 --gid ustreamer \
 && usermod ustreamer --append --groups video

COPY --chown=ustreamer:ustreamer health.sh ./

COPY --chown=ustreamer:ustreamer --from=build /opt/ustreamer/src/ustreamer.bin ./ustreamer

## Start ustreamer
USER ustreamer
EXPOSE 8080
ENTRYPOINT ["/opt/ustreamer"]
CMD ["--host=0.0.0.0", "--port=8080"]

