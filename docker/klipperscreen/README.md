This Image is built and used by [prind](.).

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
|`latest`|Refers to the most recent runtime Image.|May point to a new build within 24h, depending on code changes in the upstream repository.|
|`<git description>` <br>eg: `v0.3.8-101-g0226ba0`|Refers to a specific [git description](https://git-scm.com/docs/git-describe#_examples) in the upstream repository. eg: [KlipperScreen/KlipperScreen:v0.3.8-101-g0226ba0](https://github.com/KlipperScreen/KlipperScreen/commit/0226ba0d95fc1b8644a9d1bbf4b7cae7d936b075)|Yes|

## Targets
|Target|Description|Pushed|
|---|---|---|
|`build`|Pull Upstream Codebase and build application|No|
|`run`|Default runtime Image|Yes|