## Get Code and make
FROM debian:bookworm-slim as build

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
 && git checkout ${VERSION} \
 && rm -rf .git

RUN cd ustreamer \
 && make

## Runtime Image
FROM debian:bookworm-slim as run

RUN apt update \
 && apt install -y \
      ca-certificates \
      libevent-2.1-7 \
      libevent-pthreads-2.1-7 \
      libjpeg62-turbo \
      libbsd0 \
      libgpiod2 \
 && apt clean

WORKDIR /opt
RUN groupadd ustreamer --gid 1000 \
 && useradd ustreamer --uid 1000 --gid ustreamer \
 && usermod ustreamer --append --groups video

COPY --chown=ustreamer:ustreamer --from=build /opt/ustreamer ./ustreamer

## Start ustreamer
USER ustreamer
EXPOSE 8080
ENTRYPOINT [ "/opt/ustreamer/ustreamer"]
CMD ["--host=0.0.0.0", "--port=8080"]

