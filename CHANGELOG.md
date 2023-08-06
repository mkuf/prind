# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

<!--
## [Unreleased]
### Added
### Fixed
### Changed
### Removed
-->

## [v1.8.0] - 2023-08-06
### Added
- CHANGELOG.md
- custom/docker-compose.custom.unique-uid-gid.override.yaml
### Fixed
- Github Action Runner running out of space
### Changed
- Refactor moonraker-timelapse custom setup into an single override file
- Clarify docs for upgrading the stack related to #86
- Minimize get-info output and prompt user to upload the generated archive
- Improve command handling in get-info

**Full Changelog**: https://github.com/mkuf/prind/compare/v1.7.1...v1.8.0

## [v1.7.1] - 2023-06-22
### Changed
- All Images are now based on Debian bookworm https://github.com/mkuf/prind/pull/81
- Klipper has been upgraded from Python 2 to Python 3

**Full Changelog**: https://github.com/mkuf/prind/compare/v1.7.0...v1.7.1

## [v1.7.0] - 2023-06-17
### Added
- profile: `hostmcu` enables you to use your hosts gpio pins for an additional mcu in klipper
- klipper: add `build-hostmcu` and `hostmcu` targets to Dockerfile
- klipper: add klipper user to `tty` group
- klipper: install correct libusb packages in tools image
- docs: add hostmcu section to additional profiles

### Changed
- klipper now always runs in privileged mode and has access to host devices #77/#78
- klipper: the `mcu` image target has been renamed to `tools` resulting in images tagged with `*-tools` instead of `*-mcu`
- extra: update image tags to use the `tools` tag instead of the `mcu` tag of the klipper image
- extra: simplify simulavr compose file as klipper is running in privileged mode
- custom: update examples to run klipper in privileged mode
- docs: update klipper image documentation
- docs: update moonraker image documentation

### Removed
- removed all profiles from klipper service
- service: klipper-priv used for octoprint

⚠️ The `hostmcu` profile is supported starting with the following image:  
|Name|Tag|
|---|---|
|mkuf/klipper|[38e79df](https://hub.docker.com/layers/mkuf/klipper/38e79df/images/sha256-0986dbee88bba491cd776950670a900df3405312d31c5b64d16a0943da79c5ed?context=repo)|

**Full Changelog**: https://github.com/mkuf/prind/compare/v1.6.0...v1.7.0

## [v1.6.0] - 2023-05-28
### Added
- **profile**: add `mobileraker_companion` by @Clon1998 via https://github.com/Clon1998/mobileraker_companion/pull/29
- **custom**: example on how to use moonraker-timelapse https://github.com/mkuf/prind/issues/46
- **docs**: udev rules for serial device permissions https://github.com/mkuf/prind/issues/64

### Changed
- **fluidd**: use docker image from GHCR by @pedrolamas in https://github.com/mkuf/prind/pull/73
- **scripts**: setup-X11: create home directory for `screen` user, install `xserver-xorg-legacy` and create `Xwrapper.config` if it does not exist

**Full Changelog**: https://github.com/mkuf/prind/compare/v1.5.0...v1.6.0

## [v1.5.0] - 2023-04-07
### Added
- ARMv6 Support in https://github.com/mkuf/prind/pull/70
- missing requirements to klipper mcu image

ARMv6 support starts with these Image tags:
|Name|Tag|
|---|---|
|mkuf/klipper|[fec7ddd](https://hub.docker.com/layers/mkuf/klipper/fec7ddd/images/sha256-c35ed50bfc707149d41b5922c6def382b58db019ecb912ae14a44b85809233fa)|
|mkuf/moonraker|[31e589a](https://hub.docker.com/layers/mkuf/moonraker/31e589a/images/sha256-cf580305cb50b2506336ff3dc4503b86fe64c256348904a8432844b721b42a92)|
|mkuf/klipperscreen|[a1c602b](https://hub.docker.com/layers/mkuf/klipperscreen/a1c602b/images/sha256-3704bca307df58d7db346970a214e59e8479f8037e8ea108c5aa4260024c5405)|
|mkuf/ustreamer|[28c8599](https://hub.docker.com/layers/mkuf/ustreamer/28c8599/images/sha256-4bdefd6b27bffa44c94a9d005a273cc886e07baa254c04937d66cc6c5ee16f0e)|

**Full Changelog**: https://github.com/mkuf/prind/compare/v1.4.0...v1.5.0

## [v1.4.0] - 2023-01-01
### Added
- moonraker-telegram-bot by @nlef in https://github.com/mkuf/prind/pull/48

### Changed
- moves klipperscreen docs to the additional profiles section

**Full Changelog**: https://github.com/mkuf/prind/compare/v1.3.2...v1.4.0

## [v1.3.2] - 2022-12-18
### Added
- prind specific labels to all services

### Changed
- use map instead of list for label definitions
- update `get-info.sh` to reference prind specific labels

**Full Changelog**: https://github.com/mkuf/prind/compare/v1.3.1...v1.3.2

## [v1.3.1] - 2022-12-08
### Fixed
- log Retrieval for `scripts/get-info.sh` 

## [v1.3.0] - 2022-12-01
Thanks to Suggestions made by @derlaft in https://github.com/mkuf/prind/issues/44, Image sizes have been reduced drastically.  

### Changed
- docker: restructure Dockerfiles for klipper, moonraker and ustreamer

### Notes
Changes concerning Images are first implemented in the following Tags:
|Image|Tag|Digest|armv7 size before|armv7 size after|
|---|---|---|---|---|
|klipper|a42f615|0198c7579c77a3f18dcac2faafcda5c772ffb5492037d049d8acc50402a0be50|309.54M|82.37M|
klipper:mcu|a42f615-mcu|1623b010388115830317e867b507a5f17f2d6b8c32a58cf98f649947521a3022|553.7M|459.71M|
|moonraker|dde9bcc|98f5587e512d13c3c12bae442824c2d8eba419291d9697b835dad52efae9268b|112.24M|89.3M|
|ustreamer|bf78d8f|4d50df64cc3752af640f8d92e1c0aa4ae362372ef06fc4c6711432030259b25d|49.68M|38.12M|

**Full Changelog**: https://github.com/mkuf/prind/compare/v1.2.1...v1.3.0

## [v1.2.1] - 2022-11-26
### Changed
- klipperscreen: add libraries for python-networkmanager

**Full Changelog**: https://github.com/mkuf/prind/compare/v1.2.0...v1.2.1

## [v1.2.0] - 2022-10-27
### Added
- `custom` directory to store docker-compose files that use images from this project
- `docker-compose.custom.multiple-printers.yaml` for multi-printer setups
- `docker-compose.custom.portainer.yaml` for starting the stack in portainer

**Full Changelog**: https://github.com/mkuf/prind/compare/v1.1.1...v1.2.0

## [v1.1.1] - 2022-10-19
This release is a bugfix for v1.1.0 and fixes #41 

### Added
- moonraker|klipper: new docker volumes
`/opt/printer_data/run`, `/opt/printer_data/gcodes`, `/opt/printer_data/logs`, `/opt/printer_data/database` and `/opt/printer_data/config`

### Changed
- links in image labels now reference the exact version of prind whith wich the image was built
- moonraker|klipper: updates docs to contain the correct volume paths

### Removed
- moonraker|klipper: docker volume `/opt/printer_data`

### Notes
Changes concerning Images are first implemented in the following Tags:
|Image|Tag|Digest|
|---|---|---|
|klipper|[0d9b2cc](https://hub.docker.com/layers/mkuf/klipper/0d9b2cc/images/sha256-05904814522d941cd90b74c680f9a12fb8fb993d7ac1b223ea5dde7920f9cce3?context=repo)<br>[0d9b2cc-mcu](https://hub.docker.com/layers/mkuf/klipper/0d9b2cc-mcu/images/sha256-b93a6c3a386f45956d96fa8405fb786bd00c77d527106e56a7777cadeea070b6?context=repo)|`sha256:05904814522d941cd90b74c680f9a12fb8fb993d7ac1b223ea5dde7920f9cce3`<br>`sha256:b93a6c3a386f45956d96fa8405fb786bd00c77d527106e56a7777cadeea070b6`|
|moonraker|[4954cc7](https://hub.docker.com/layers/mkuf/moonraker/4954cc7/images/sha256-03d57c0d8b73d54c99dc347e4735ba3ec777b5a4f49f845e1e05d600018589a7?context=repo)|`sha256:03d57c0d8b73d54c99dc347e4735ba3ec777b5a4f49f845e1e05d600018589a7`|

**Full Changelog**: https://github.com/mkuf/prind/compare/v1.1.0...v1.1.1

## [v1.1.0] - 2022-10-18
This release is mainly to support the Changes to Moonraker proposed in https://github.com/Arksine/moonraker/pull/491 and fixes #40.

### Added
- moonraker|klipper: new docker volume `/opt/printer_data`
- restart directive for simulavr service in `docker-compose.extra.simulavr.yaml`
- error Message to `get-info.sh` if the script is run from the wrong directory
- extraction of additional information in `get-info.sh`
- additional labels for docker Images to reference the version of prind

### Changed
- moonraker|klipper: update `docker-compose.yaml` to mount volumes within the new directory structure
- moonraker|klipper: update `CMD`s to use new directory structure
- `moonraker.cfg` is renamed to `moonraker.conf`
- moonraker: `klippy_uds_address` adheres to the new directory structure
- moonraker: `validate_service` has been disabled
- updates the Docs for the Klipper and Moonraker Images accordingly

### Removed
- moonraker|klipper: docker volumes `/opt/run`, `/opt/cfg`, `/opt/gcode`, `/opt/db` 
- moonraker: the explicit command definition in `docker-compose.yaml` has been removed

### Notes
Changes concerning Images are first implemented in the following Tags:
|Image|Tag|Digest|
|---|---|---|
|klipper|[0d9b2cc](https://hub.docker.com/layers/mkuf/klipper/0d9b2cc/images/sha256-eba5246a3cd2ed4223e790e70fde9c12f2a69ce813da695e5ea054615456d10c?context=repo)<br>[0d9b2cc-mcu](https://hub.docker.com/layers/mkuf/klipper/0d9b2cc-mcu/images/sha256-078fe53d09ad91f91096c9c3bbd40c9742140404b18f1c6c873624bbbc81d04e?context=repo)|`sha256:eba5246a3cd2ed4223e790e70fde9c12f2a69ce813da695e5ea054615456d10c` <br>`sha256:078fe53d09ad91f91096c9c3bbd40c9742140404b18f1c6c873624bbbc81d04e`|
|moonraker|[f745c2c](https://hub.docker.com/layers/mkuf/moonraker/f745c2c/images/sha256-3ba2e92d9f7975605c834f8e6bf41005138640bc1decc9c0ba6d4745bc18e233?context=repo)|`sha256:3ba2e92d9f7975605c834f8e6bf41005138640bc1decc9c0ba6d4745bc18e233`|

**Full Changelog**: https://github.com/mkuf/prind/compare/v1.0.0...v1.1.0

## [v1.0.0] - 2022-07-09
This is the first major release of prind with a plethora of changes since v0.5.4. Have fun. 🎉  

### Added
- Support for klipper input shaper
- `latest` tag to `nightly` images to achieve compatibility with docker defaults
- `README.md` Files for all Docker Images in their respective directory under `docker/`
- Naming convention for additional compose files `docker-compose.extra.*.yaml`
- labels to docker images with additional infos about their origin
- `script/get-info.sh` to generate support files to assist in troubleshooting

### Changed
- simplified instructions on building mcu code
- use the official mainsail docker image #29 
- define commands as strings instead of yaml lists in all compose files

### Removed
- unused octoprint image from `docker/octoprint`
- `container_name` from all compose files to use autogenerated names
- mainsail dockerfile and github workflow #29 
- redundant command definitions for services

### Notes
Changes concerning Images are first implemented in the following Tags:
|Image|Tag|
|---|---|
|klipper|[24a1b50](https://hub.docker.com/layers/klipper/mkuf/klipper/24a1b50/images/sha256-aa17c7a9a946653cf12c3ae9a44a9ab03a265fa31bfecc20824619cf754a68cd?context=repo)<br>[24a1b50-mcu](https://hub.docker.com/layers/klipper/mkuf/klipper/24a1b50-mcu/images/sha256-d588551af3f072ec5824e7dfdaaa8af37d8a23cbbb8f9918cb778a5e606539e1?context=repo)|
|moonraker|[d37f91c](https://hub.docker.com/layers/moonraker/mkuf/moonraker/d37f91c/images/sha256-002deb962ef6932f7ac6dde96b08e605958984c1b8777c31b313964c1fd4a894?context=repo)|
|klipperscreen|[050cc13](https://hub.docker.com/layers/klipperscreen/mkuf/klipperscreen/050cc13/images/sha256-ce11b64166e6f3baa22d239f5a5288ff6fe5d1b3f1e14e63ba85886f935de898?context=repo)|
|ustreamer|[db5b9d3](https://hub.docker.com/layers/ustreamer/mkuf/ustreamer/db5b9d3/images/sha256-5de0a14ae62ad8f97871d1be1e73b32cb11f8f7f26e974af50f0742806e1694d?context=repo)|


**Full Changelog**: https://github.com/mkuf/prind/compare/v0.5.4...v1.0.0

## [v0.5.4] - 2022-06-13
### Added
- Inital configuration for Octoprint in `config/octoprint.yaml` 

### Changed
- Octoprints' Config is no longer stored within its volume and is now part of the common config directory

## Notes ⚠️ 
If you are already using prind with Octoprint, copy your `config.yaml` from the octoprint volume to `config/octoprint.yaml` before upgrading, otherwise all your octoprint settings will be lost.
You can use docker compose to achieve this, e.g.
```
docker compose --profile octoprint cp octoprint:/octoprint/octoprint/config.yaml ./config/octoprint.yaml
```

## [v0.5.3] - 2022-04-18
### Added
- `/webcam` endpoint provides full access to all ustreamer urls e.g `/webcam/stream`, `/webcam/snapshot`, `/webcam/?action=stream`

### Changed
- `ustreamer` service is now called `webcam` to streamline naming for multi-cam setups
- updates docs for multi-cam setups
- adds the `klipperscreen` profile to `klipper` and `moonraker` services

### Removed
- `/stream` endpoint

## Notes
This release changes the streaming URL for ustreamer and renames the `ustreamer` service to `webcam`.  
If you are currently accessing your Webcam via `http://yourhost/stream`, you'll have to update URLs to `http://yourhost/webcam/stream`
Be sure to execute `docker compose up`  with the `--remove-orphans` option to avoid the depricated ustreamer service to block your webcam.
e.g.
```
docker compose --profile fluidd up -d --remove-orphans
```

## [v0.5.2] - 2022-03-30
### Fixes
- Mounts `/dev/null` in Places, where Moonraker expects klipper directories to get rid of warnings described in #14 

## [v0.5.1] - 2022-03-25

### Changed
- klipperscreen: mounts the hosts localtime into the service
- klipperscreen: removes the dependency from moonraker

### Fixes
- moonraker: adds missing libraries to runtime image for preview rendering

## [v0.5.0] - 2022-03-23
### Added
- systemd bindings to moonraker container

### Notes
It is now possible to run `shutdown`, `reboot` and `systemctl` from within the moonraker container and **control the pyhsical host**.  
This makes it possible to safely shutdown your host from the various GUI implementations or via GCODE. See [moonraker/docs/configuration.md](https://github.com/Arksine/moonraker/blob/4b27e5e41d754ba91c7baf6db124721892d2cbc5/docs/configuration.md#machine) for further Infos.  

As of writing this (23.03.2022 23:48), there has been no Image built that supports these changes. Be sure to wait for the next nightly to be pushed to the docker registry at [mkuf/moonraker](https://hub.docker.com/r/mkuf/moonraker/tags) before expecting this feature to work.

**Update:**
The first Image to Support this change is the current (24.03.2022) nightly: [mkuf/moonraker:4b27e5e](https://hub.docker.com/layers/moonraker/mkuf/moonraker/4b27e5e/images/sha256-83de5a9b7119a28f1ff2a96c5215dbf154d1d465e9f4fa798ac33ce9be8929f6)

## [v0.4.0] - 2022-03-22
### Added
- official Logos for prind

### Changed
- script/setup-X11: display prind logo instead of xterm while waiting for klipperscreen
- docs: minor wording changes for klipperscreen

## [v0.3.0] - 2022-03-17
### Added
- KlipperScreen (Service, Dockerfile, Docs, Workflow)
- X11 Setup Script

## [v0.2.1] - 2022-03-10
### Changed
- updated docker-compose.simulavr.yaml to be compatible with octoprint

## [v0.2.0] - 2022-03-09
### Added
- simulavr service for debugging the stack

### Changed
- User specific config is now located in `docker-compose.override.yaml` instead of `docker-compose.yaml` directly. Consider migrating your changes to the override file if you intend to use the new simulavr service

## [v0.1.1] - 2022-02-28
### Fixed
- Service dependencies

## [v0.1.0] - 2022-02-26
- Initial release