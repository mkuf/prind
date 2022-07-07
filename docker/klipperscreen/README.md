# KlipperScreen packaged in Docker
## What is KlipperScreen?

>KlipperScreen is a touchscreen GUI that interfaces with Klipper via Moonraker. It can switch between multiple printers to access them from a single location, and it doesn't even need to run on the same host, you can install it on another device and configure the IP address to access the printer.

_via https://klipperscreen.readthedocs.io/en/latest/_

## Usage
This Image requires XServer on the host and also host network access. You can use [setup-X11.sh](../../scripts/setup-X11.sh) for a basic X11 setup to use with this Image.

Create `klipperscreen.conf`, then run the container.

#### Run
```bash
docker run \
  --network host \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $(pwd)/klipperscreen.conf:/opt/cfg/klipperscreen.conf \
  mkuf/klipperscreen:latest
```
#### Compose
```yaml
services:
  klipperscreen:
    image: mkuf/klipperscreen:latest
    network_mode: host
    volumes:
      - /tmp/.X11-unix:/tmp/.X11-unix
      - ./klipperscreen.conf:/opt/cfg/klipperscreen.conf
```

## Defaults
|Entity|Description|
|---|---|
|User| `root (0:0)` |
|Workdir|`/opt`|
|Entrypoint|`/opt/venv/bin/python klipperscreen/screen.py`|
|Cmd|`-c cfg/klipperscreen.conf`|

## Ports
none

## Volumes
|Volume|Description|
|---|---|
|`/opt/cfg`|Config directory to host `klipperscreen.conf`|

## Tags
|Tag|Description|Static|
|---|---|---|
|`latest`/`nightly`|Refers to the most recent runtime Image.|May point to a new build within 24h, depending on code changes in the upstream repository.|
|`<7-digit-sha>` <br>eg: `37c10fc`|Refers to a specific commit SHA in the upstream repository. eg: [jordanruthe/KlipperScreen:37c10fc](https://github.com/jordanruthe/KlipperScreen/commit/37c10fc8b373944ea138574a44bbfa0a5dcf0a98)|Yes|

## Targets
|Target|Description|Pushed|
|---|---|---|
|`build`|Pull Upstream Codebase and build application|No|
|`run`|Default runtime Image|Yes|