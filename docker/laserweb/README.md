This Image is built and used by [prind](.).

# Laserweb4 packaged in Docker
## What is Laserweb?

> LaserWeb / CNCWeb is a full CAM & Machine Control Program for Laser/CNC/Plotter/Plasma applications.  

_via https://laserweb.yurl.ch/_

This image contains the frontend from https://github.com/ssendev/LaserWeb4.  
It still requires a compatible backend like [moonraker](https://github.com/Arksine/moonraker) or the [lw.comm-server](https://github.com/LaserWeb/lw.comm-server) if machine control is desired.

## Usage
#### Run
```bash
docker run -p 80:80 mkuf/laserweb:latest
```
#### Compose
```yaml
services:
  laserweb:
    image: mkuf/laserweb:latest
    ports:
      - "80:80"
```
## Defaults
|Entity|Description|
|---|---|
|User| `nginx (101:101)` |
|Workdir||
|Entrypoint|`/docker-entrypoint.sh`|
|Cmd|`nginx -g daemon off;`|

## Ports
|Port|Description|
|---|---|
|`80/tcp`|Default HTTP Port|

## Volumes
none

## Tags
|Tag|Description|Static|
|---|---|---|
|`latest`|Refers to the most recent runtime Image.|May point to a new build within 24h, depending on code changes in the upstream repository.|
|`<git description>` <br>eg: `v4.1-1-g3c7564d`|Refers to a specific git description in the upstream repository. |Yes|

## Targets
|Target|Description|Pushed|
|---|---|---|
|`build`|Pull Upstream Codebase and build application|No|
|`run`|Default runtime Image based on `library/nginx`|Yes|