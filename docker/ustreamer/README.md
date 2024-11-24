This Image is built and used by [prind](.).

# ustreamer packaged in Docker
## What is ustreamer?

>µStreamer is a lightweight and very quick server to stream MJPEG video from any V4L2 device to the net. All new browsers have native support of this video format, as well as most video players such as mplayer, VLC etc. µStreamer is a part of the Pi-KVM project designed to stream VGA and HDMI screencast hardware data with the highest resolution and FPS possible.

_via https://github.com/pikvm/ustreamer_

## Usage
By default, ustreamer is looking for device `/dev/video0`. A docker device binding can be utilized to provide this device without the need to change the default CMD.

#### Run
```bash
docker run -p 8080:8080 --device /dev/video0:/dev/video0 mkuf/ustreamer:latest
```
#### Compose
```yaml
services:
  ustreamer:
    image: mkuf/ustreamer:latest
    ports:
      - "8080:8080"
    devices:
      - /dev/video0:/dev/video0
```

## Defaults
|Entity|Description|
|---|---|
|User| `ustreamer (1000:1000)` |
|Workdir|`/opt`|
|Entrypoint|`/opt/ustreamer`|
|Cmd|`--host=0.0.0.0 --port=8080`|

## Ports
|Port|Description|
|---|---|
|`8080/tcp`|Default WebUi Port|

## Volumes
none

## Tags
|Tag|Description|Static|
|---|---|---|
|`latest`|Refers to the most recent runtime Image.|May point to a new build within 24h, depending on code changes in the upstream repository.|
|`<git description>` <br>eg: `v5.51-1-g3c7564d`|Refers to a specific [git description](https://git-scm.com/docs/git-describe#_examples) in the upstream repository. eg: [pikvm/ustreamer:v5.51-1-g3c7564d](https://github.com/pikvm/ustreamer/commit/3c7564da19e32badeb858d73bcf98875349dfaff)|Yes|

## Targets
|Target|Description|Pushed|
|---|---|---|
|`build`|Pull Upstream Codebase and build application|No|
|`run`|Default runtime Image|Yes|

## Healthcheck
`/opt/health.sh` gets executed every 5s inside the container.  

> Be aware that enabling health checks in docker may increase CPU usage drastically.  
> In tests, cpu usage of the container was doubled when executing the healtch check every 30s and increased sixfold when executing every 5s.  
> This may lead to resource shortages on low powered host and unwanted behaviour  

The script does the following:
* gets the JSON structure with the state of the server
* Checks the following values
  * `.ok` is set to `true`, which indicates ustreamer is working
  * `.result.source.online` is set to `true`, which indicates the source (webcam) is returning an image rather than `NO SIGNAL`
* If one of the above requirements is not met, the script exits with a failure state to indicate the container is unhealthy

Compose example:
```yaml
services:
  ustreamer:
    healthcheck:
      test: ["bash", "/opt/health.sh"]
      interval: 30s
```