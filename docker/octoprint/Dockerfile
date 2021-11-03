## Install OctoPrint and Plugins in venv
FROM python:3 as build

ARG VERSION=1.7.2

WORKDIR /opt
COPY plugins.txt plugins.txt
RUN python -m venv venv \
 && venv/bin/pip install OctoPrint==${VERSION} \
 && venv/bin/pip install -r plugins.txt

## Runtime Image
FROM python:3-slim as run

WORKDIR /opt
COPY --from=build /opt/venv venv
COPY apt.txt apt.txt

RUN apt update \
 && apt install -y $(grep -vE "^\s*#" apt.txt  | tr "\n" " ") \
 && apt clean

RUN mkdir run cfg
RUN groupadd octoprint --gid 1000 \
 && useradd octoprint --uid 1000 --gid octoprint \
 && usermod octoprint --append --groups dialout \
 && chown -R octoprint:octoprint /opt/*

 USER octoprint
 EXPOSE 5000
 VOLUME ["/opt/run", "/opt/cfg"]
 ENTRYPOINT ["/opt/venv/bin/octoprint", "serve"]
 CMD ["-b", "/opt/cfg"]