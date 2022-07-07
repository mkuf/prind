# Mainsail packaged in Docker
## What is Mainsail?

>Mainsail makes Klipper more accessible by adding a lightweight, responsive web user interface, centred around an intuitive and consistent design philosophy.

_via https://docs.mainsail.xyz/_

## Usage
#### Run
```bash
docker run -p 80:80 mkuf/mainsail:latest
```
#### Compose
```yaml
services:
  mainsail:
    image: mkuf/mainsail:latest
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
|`latest`/`nightly`|Refers to the most recent runtime Image.|May point to a new build within 24h, depending on code changes in the upstream repository.|
|`<7-digit-sha>` <br>eg: `1e0645b`|Refers to a specific commit SHA in the upstream repository. eg: [mainsail-crew/mainsail:1e0645b](https://github.com/mainsail-crew/mainsail/commit/1e0645be6e54abed1e30d54830511ae8f1fad54c)|Yes|

## Targets
|Target|Description|Pushed|
|---|---|---|
|`build`|Pull Upstream Codebase and build application|No|
|`run`|Default runtime Image based on `library/nginx`|Yes|