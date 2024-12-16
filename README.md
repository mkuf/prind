<p align=center><img src=img/prind-logo.png height=400px></p>

# prind
[![Build and Publish Images](https://github.com/mkuf/prind/actions/workflows/image-build-and-publish-schedule.yaml/badge.svg)](https://github.com/mkuf/prind/actions/workflows/image-build-and-publish-schedule.yaml)

prind allows you to run the software for your 3D printer in Docker containers, eliminating any dependencies on the operating system.  
This means you can use end-of-life or cutting-edge operating systems, and anything in between.

With a single command, you can start up Klipper and its accompanying applications.

## Supported Applications
<details>
<summary>Click to expand</summary>

|   |Name|Image source|Docs|
|:---:|------|--------------|---|
|<img src="https://raw.githubusercontent.com/Klipper3d/klipper/master/docs/img/klipper-logo.png" width=30px>|[Klipper](https://github.com/Klipper3d/klipper)|prind @ [docker/klipper](docker/klipper)|[Getting Started](#getting-started)|
|<img src="https://avatars.githubusercontent.com/u/9563098?v=4" width=30px>|[Moonraker](https://github.com/Arksine/moonraker)|prind @ [docker/moonraker](docker/moonraker)|[Getting Started](#getting-started)|
|<img src="https://raw.githubusercontent.com/mainsail-crew/docs/master/assets/img/logo.png" width=30px>|[Mainsail](https://github.com/mainsail-crew/mainsail)|`upstream`|[Starting the Stack](#starting-the-stack)|
|<img src="https://raw.githubusercontent.com/fluidd-core/fluidd/develop/docs/assets/images/logo.svg" width=30px>|[Fluidd](https://github.com/fluidd-core/fluidd)|`upstream`|[Starting the Stack](#starting-the-stack)|
|<img src="https://github.com/OctoPrint/OctoPrint/blob/master/docs/images/octoprint-logo.png?raw=true" width=30px>|[Octoprint](https://github.com/OctoPrint/OctoPrint)|`upstream`|[Starting the Stack](#starting-the-stack)|
|<img src="https://avatars.githubusercontent.com/u/91093001?s=200&v=4" width=30px>|[KlipperScreen](https://github.com/KlipperScreen/KlipperScreen)|prind @ [docker/klipperscreen](docker/klipperscreen)|[Additional Profiles](#klipperscreen)|
|<img src="https://avatars.githubusercontent.com/u/52351624?s=48&v=4" width=30px>|[moonraker-telegram-bot](https://github.com/nlef/moonraker-telegram-bot)|`upstream`|[Additional Profiles](#moonraker-telegram-bot)|
|<img src="https://github.com/Clon1998/mobileraker/blob/master/assets/icon/ic_launcher_foreground.png?raw=true" width=30px>|[mobileraker_companion](https://github.com/Clon1998/mobileraker_companion)|`upstream`|[Additional Profiles](#mobileraker_companion)|
|<img src="https://avatars.githubusercontent.com/u/46323662?s=200&v=4" width=30px>|[moonraker-obico](https://github.com/TheSpaghettiDetective/moonraker-obico)|`upstream`|[Additional Profiles](#moonraker-obico)|
|<img src="https://raw.githubusercontent.com/Donkie/Spoolman/master/client/icons/spoolman.svg" width=30px>|[Spoolman](https://github.com/Donkie/Spoolman)|`upstream`|[Additional Profiles](#spoolman)|
|<img src="https://avatars.githubusercontent.com/u/41749659?s=200&v=4" width=30px>|[µStreamer](https://github.com/pikvm/ustreamer)|prind @ [docker/ustreamer](docker/ustreamer)|[Add your Configuration](#add-your-configuration-to-docker-composeoverrideyaml)<br>[Multiple Webcams](https://github.com/mkuf/prind?tab=readme-ov-file#multiple-webcams)|
</details>

## Getting started
This guide requires _Docker_ and _Docker Compose v2_ on your machine.  
Follow the official guides to install and set them up:

* [Install Docker on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
* [Install Docker Compose v2](https://docs.docker.com/compose/cli-command/#installing-compose-v2)

Clone this repository onto your Docker host using Git:
```
git clone https://github.com/mkuf/prind
```
Unless otherwise specified, all commands mentioned in the documentation should be run from the root of the repository.

### Build the MCU Code
Before using Klipper, you'll have to build and flash the microcontroller-code for your printers mainboard.  
As this can be accomplished via docker, we can create an alias that replaces `make` with the appropriate docker compose command. After setting this alias, follow the Instructions on finding your printer, building and flashing the microcontroller found in the [Klipper Docs](https://www.klipper3d.org/Installation.html#building-and-flashing-the-micro-controller).  

Adapted from the official Docs, a generic Build would look like this.
```
alias make="docker compose -f docker-compose.extra.make.yaml run --rm make"

make menuconfig
make
make flash FLASH_DEVICE=/dev/serial/by-id/<my printer>
```

If your Board can be flashed via SD-Card, you may want to omit `make flash` and retrieve the `klipper.bin` from the `out` directory that is created by `make`. Follow your boards instructions on how to proceed with flashing via SD-Card.

### Add your Configuration to docker-compose.override.yaml
Locate the `webcam` Service within `docker-compose.override.yaml` and update the `device` Section with the Device Name of your Webcam.  
In this example, the Webcam is using device `/dev/video0`. Do not edit any other lines.
```yaml
  webcam:
    <<: *ustreamer-svc
    devices:
      - /dev/video0:/dev/webcam
    labels:
      - "traefik.enable=true"
      - "traefik.http.services.webcam.loadbalancer.server.port=8080"
      - "traefik.http.routers.webcam.rule=PathPrefix(`/webcam`)"
      - "traefik.http.routers.webcam.entrypoints=web"
      - "traefik.http.middlewares.webcam.stripprefix.prefixes=/webcam"
      - "traefik.http.routers.webcam.middlewares=webcam"
```

### Configuring Klipper/Moonraker
All Runtime Configs are stored within `config` of this Repo.  
* Update `config/printer.cfg` with your Klipper config, set the serial device and make sure to not remove the existing Macros as they are required by fluidd/mainsail. See [Klipper3d Docs](https://www.klipper3d.org/Config_Reference.html) for Reference
* Make sure to update `cors_domains` and `trusted_clients` within `moonraker.cfg` to secure your moonraker api from unwanted access. See [Moonraker Docs](https://moonraker.readthedocs.io/en/latest/configuration/) for Reference

### Starting the stack
There are currently 3 frontend Profiles to choose from, depending on the Web Frontend you'd like to use.
* fluidd
* mainsail
* octoprint (w/o moonraker)

Starting the stack comes down to:
```
docker compose --profile <profile> up -d
```
e.g.
```
docker compose --profile fluidd up -d
```

Switching between profiles requires the whole stack to be torn down before starting another Frontend.  
Running two Frontends at the same time is currently not supported behind a proxy.
Switching from fluidd to mainsail would look like this: 
```
docker compose --profile fluidd down
docker compose --profile mainsail up -d
```

### Additional Profiles
Docker compose allows for multiple profiles to be started at once.  
You may combine any of the above frontend profiles with any number of the following additional profiles.  

Be sure to always use the same set of profiles when updating the stack, otherwise services may be orphaned or the stack is behaving in an unpredictable way. 

#### hostmcu
The `hostmcu` profile enables you to use your host as secondary mcu for klipper.  
See the [Klipper Docs](https://www.klipper3d.org/RPi_microcontroller.html) for more information on this Topic.

Uncomment the following lines in `printer.cfg`
```
[mcu host]
serial: /opt/printer_data/run/klipper_host_mcu.tty
```
then start the stack with

```
docker compose --profile mainsail --profile hostmcu up -d
```

After the hostmcu container is started, you may check for available gpio chips with

```
docker compose exec -it hostmcu gpiodetect
```

and check the pin number and pin availability with

```
docker compose exec -it hostmcu gpioinfo
```

#### KlipperScreen
[KlipperScreen by jordanruthe](https://github.com/jordanruthe/KlipperScreen) can be enabled via the `klipperscreen` Profile.  

It requires a X11 Server on your machine that the Container can connect to.  
Locate the setup Script for X11 within `scripts/` and run it from the root directory of this repository as user root.
It creates a User, installs and configures X11 and creates a Systemd Service for xinit.
```
cd prind/
./scripts/setup-X11.sh
```

The Prind Logo should now be displayed on your screen.  
If this is not the case, check the scripts output for errors.  
Otherwise, proceed to start/update the Stack.

```
docker compose --profile fluidd --profile klipperscreen up -d
```

#### Moonraker-Telegram-Bot
[moonraker-telegram-bot by nlef](https://github.com/nlef/moonraker-telegram-bot) can be enabled via the `moonraker-telegram-bot` Profile  

Add your `bot_token` and `chat_id` to `config/telegram.conf`.  
See the [configuration reference](https://github.com/nlef/moonraker-telegram-bot/wiki/Sample-config) for further configuration Options.

```
docker compose --profile mainsail --profile moonraker-telegram-bot up -d
```

#### mobileraker_companion
[mobileraker_companion by Clon1998](https://github.com/Clon1998/mobileraker_companion) can be enabled via the `mobileraker_companion` Profile.

The default configuration provided with this repository contains everything needed to start the service and receive notifications via the [Mobileraker App](https://github.com/Clon1998/mobileraker). See the [configuration reference](https://github.com/Clon1998/mobileraker_companion#companion---config) for further configuration Options.

```
docker compose --profile mainsail --profile mobileraker_companion up -d
```

#### moonraker-obico
> This profile is incompatible with OctoPrint, choose Fluidd or Mainsail instead.

[moonraker-obico by TheSpaghettiDetective](https://github.com/TheSpaghettiDetective/moonraker-obico) can be enabled via the `moonraker-obico` Profile.  

The default configuration provided with this repository contains everything needed to access the webcam and use the tunnel with obico Cloud. This requires an account at https://obico.io.  
If you use a self hosted instance of [obico-server](https://github.com/TheSpaghettiDetective/obico-server), you'll have to change the `[server].url` at `config/moonraker-obico.cfg`.  

For further configuration options, see the [Official Documentation](https://www.obico.io/docs/user-guides/moonraker-obico/config/).

Follow these steps to link your printer and start the profile:

1. Add a new `Klipper`-Type Printer via the Webinterface
2. Klick `Next` when prompted to *Install Obico for Klipper*, not executing the shown Commands
3. Change to the root of the prind repository and start the linking process
```bash
docker compose -f docker-compose.extra.link-obico.yaml run --rm link-obico
```
4. Enter the *6-digit verification code*
5. Check if `[server].auth_token` is set in `config/mooonraker-obico.cfg`
6. Start the stack
```bash
docker compose --profile mainsail --profile moonraker-obico up -d
```

#### Spoolman
[Spoolman by Donkie](https://github.com/Donkie/Spoolman) can be enabled via the `spoolman` Profile.  

Uncomment the spoolman section in `moonraker.conf` and add your printers Hostname or IP to the server URL.  
The stack can then be started by specifying the `spoolman` profile. 
```bash
docker compose --profile fluidd --profile spoolman up -d
```

Navigate to `http://<yourprinter>/spoolman` to access the spool manager webinterface.

## Updating
Images are built daily and tagged with `latest` and the [git description](https://git-scm.com/docs/git-describe#_examples) of the remote repo. 
Example: 

* `mkuf/klipper:latest`
* `mkuf/klipper:v0.12.0-114-ga77d0790`

The `latest` Tag will point to a new Image within 24h.  
The descriptive Tag `v0.12.0-114-ga77d0790` will remain and refers to [Klipper3d/klipper:v0.12.0-114-ga77d0790](https://github.com/Klipper3d/klipper/commit/a77d07907fdfcd76f7175231caee170db205ff04)

Updating can be handled via docker-compose.  
docker-compose.yaml uses latest tags for all Images contained in this Repository.  
Compose will download all current Images and replace them when starting the stack again.  
Make sure to include _all_ profiles that you specified at stack startup when pulling images.  
```
docker compose --profile <profile> pull
docker compose --profile <profile> up -d
``` 

## Advanced Topics
### Device permissions
Adjusting permissions for devices connected to your host may become necessary, especially if you're using a non-Debian-based distribution with varying numerical group IDs.  

You can accomplish this by crafting a udev rule tailored to your specific device on your host system. Refer to your operating system's manual for instructions on configuring udev rules.  

Typically, this involves creating a `*.rules` file within `/etc/udev/rules.d` and appending a single line to it.  
Consult the table below for the appropriate rule corresponding to your device type. Ensure to include your device's specific `idVendor` and `idProduct`, which can be identified using the `lsusb` command.

| Device Type | Group Name | GID  | Udev Rule                                                                                            |
|-------------|------------|------|------------------------------------------------------------------------------------------------------|
| Serial Port | `dialout`  | `20` | `ACTION=="add",SUBSYSTEM=="tty",ATTRS{idVendor}=="0000",ATTRS{idProduct}=="0000",GROUP="20"`         |
| Webcam      | `video`    | `44` | `ACTION=="add",SUBSYSTEM=="video4linux",ATTRS{idVendor}=="0000",ATTRS{idProduct}=="0000",GROUP="44"` |

### Input Shaper Calibration
Using input shaper requires an accelerometer.  
If you choose to connect this to your hosts GPIO pins, make sure to enable the `hostmcu` profile described in the `Additional Profiles` section above.

Follow the Docs on [Measuring Resonances](https://www.klipper3d.org/Measuring_Resonances.html), to set up your Printer.  

After running `TEST_RESONANCES` or `SHAPER_CALIBRATE`, Klipper generates csv output in /tmp. To further analyze this data, it has to be extracted from the running klipper container.
```
mkdir ./resonances

docker compose exec klipper ls /tmp
  resonances_x_20220708_124515.csv  resonances_y_20220708_125150.csv

docker compose cp klipper:/tmp/resonances_x_20220708_124515.csv ./resonances/
docker compose cp klipper:/tmp/resonances_y_20220708_125150.csv ./resonances/
```

`docker-compose.extra.calibrate-shaper.yaml` is set up to run `calibrate_shaper.py`, so any options supported by the script can also be used with the container. 
Set an alias to save yourself from typing the the docker compose command multiple times. The generated Images are located besides the csv files in `./resonances`
```
alias calibrate_shaper="docker compose -f docker-compose.extra.calibrate-shaper.yaml run --rm calibrate_shaper"

calibrate_shaper resonances_x_20220708_124515.csv -o cal_x.png
  [...]
  Recommended shaper is ei @ 90.2 Hz

calibrate_shaper resonances_y_20220708_125150.csv -o cal_y.png
  [...]
  Recommended shaper is mzv @ 48.2 Hz
```

### Use CANBUS
CAN Devices are network devices in the Hosts network namespace. Granting access for containers requires running them in host network mode.  
Add the following snippet to your `docker-compose.override.yaml` and restart the stack.  
Any further configuration has to be done in klipper, see the [official Klipper Docs](https://www.klipper3d.org/CANBUS.html)
```yaml
services:
  klipper:
    network_mode: host
```


### Change Execution Options
The Entrypoint for all Docker Images within this Repo are the actual Applications, which are run at container execution time.  
This makes it possible to set command line Arguments for the Apps as Docker Command.  
Within docker-compose.yaml commands are already set, you may override them within `docker-compose.override.yaml` to fit your needs. 
Example from service Klipper:
```yaml
  command:
    - "-I"
    - "run/klipper.tty"
    - "-a"
    - "run/klipper.sock"
    - "cfg/printer.cfg"
```

### Multiple Webcams
The Ustreamer Service is already templated to be easily reused for multi-webcam Setups.  
To add a new Ustreamer Service, simply add the following snippet to `docker-compose.override.yaml`.  
Notice, that all service names, container names and traefik labels need to be unique while the right side of the passed Device (`:/dev/webcam`) always stays the same.
Hence replace webcam2 with webcam3 and so on for every webcam you add and update the physical device that gets passed to the container.
```yaml
  webcam2:
    <<: *ustreamer-svc
    devices:
      - /dev/video1:/dev/webcam
    labels:
      org.prind.service: webcam2
      traefik.enable: true
      traefik.http.services.webcam2.loadbalancer.server.port: 8080
      traefik.http.routers.webcam2.rule: PathPrefix(`/webcam2`)
      traefik.http.routers.webcam2.entrypoints: web
      traefik.http.middlewares.webcam2.stripprefix.prefixes: /webcam2
      traefik.http.routers.webcam2.middlewares: webcam2
```

### Building Docker images locally
If you'd like to customize the provided Docker Images, you may edit the Dockerfiles within the `docker/<service>` Directory.  
Images are build in multiple stages, the final stage is called `run`. Based on this, you can update Service definitions within `docker-compose.override.yaml` to build Images locally.

Example: Build Moonraker  
Update the `image:` name and add a `build` config:
```yaml
  moonraker:
    image: moonraker:latest
    build:
      context: docker/moonraker
      target: run
```

### Healthchecks
The Klipper, Moonraker, and Ustreamer images include scripts to monitor the overall health of the application. By default, health checks are **disabled** to avoid high CPU usage, which can cause unwanted behavior on low-powered machines.

In tests, container CPU usage **doubled** when health checks were performed every 30 seconds and increased **sixfold** when performed every 5 seconds.

To enable health checks, you can add them to your docker-compose.override.yaml file. Refer to the [Compose file documentation]((https://docs.docker.com/reference/compose-file/services/#healthcheck)) for guidance on customizing these checks.

```yaml
services:
  klipper:
    healthcheck:
      test: ["python3", "/opt/health.py"]
      interval: 30s
  moonraker:
    healthcheck:
      test: ["bash", "/opt/health.sh"]
      interval: 30s
  webcam:
    healthcheck:
      test: ["bash", "/opt/health.sh"]
      interval: 30s
```

### Enable Mainsail remoteMode
In case Moonraker is not situated on the same Host as Mainsail, you'll have to enable remoteMode in Mainsail to set up a remote Printer. This mirrors the behaviour of https://my.mainsail.xyz.

1. Create `config/mainsail.json` with the following Contents
```json
{
    "remoteMode":true
}
```
2. Add the newly created File as a Volume to the mainsail Service
```yaml
  mainsail:
    volumes:
      - ./config/mainsail.json:/usr/share/nginx/html/config.json
```

### Debugging the Stack
Debugging the Stack without printer hardware is challenging, as klipper requires a mcu to operate.  
For this purpose, you can build a service that emulates a mcu with simulavr, as suggested by the [Klipper Docs](https://github.com/Klipper3d/klipper/blob/master/docs/Debugging.md).  

The simulavr Image is part of the Dockerfile for Klipper but is not pushed to any registry, so it needs to be built when needed.  

Locate the `docker-compose.extra.simulavr.yaml` in the repository and set the `VERSION` Build-Arg to any Git Reference from [Klipper3d/klipper](https://github.com/Klipper3d) that you would like the mcu code to be compatible with. 

This example builds the mcu code from [Klipper3d/klipper:d75154d](https://github.com/Klipper3d/klipper/commit/d75154d695efb1338cbfff061d226c4f384d127b)
```yaml
    build:
      context: docker/klipper
      target: build-simulavr
      args: 
        VERSION: d75154d695efb1338cbfff061d226c4f384d127b
```

Then start the Stack
```
docker compose \
  --profile mainsail \
  -f docker-compose.yaml \
  -f docker-compose.extra.simulavr.yaml \
  up -d
```
