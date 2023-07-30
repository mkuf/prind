<p align=center><img src=img/prind-logo.png height=400px></p>

# prind
[![Image: Klipper](https://github.com/mkuf/prind/actions/workflows/klipper.yaml/badge.svg)](https://github.com/mkuf/prind/actions/workflows/klipper.yaml)
[![Image: Moonraker](https://github.com/mkuf/prind/actions/workflows/moonraker.yaml/badge.svg)](https://github.com/mkuf/prind/actions/workflows/moonraker.yaml)
[![Image: Klipperscreen](https://github.com/mkuf/prind/actions/workflows/klipperscreen.yaml/badge.svg)](https://github.com/mkuf/prind/actions/workflows/klipperscreen.yaml)
[![Image: Ustreamer](https://github.com/mkuf/prind/actions/workflows/ustreamer.yaml/badge.svg)](https://github.com/mkuf/prind/actions/workflows/ustreamer.yaml)

prind allows you to run the Software for your 3D Printer in Docker containers.  
With a single Command, you can start up klipper and choose between multiple Frontends. 

Currently supported Frontends:
  * Octoprint (via [Dockerhub](https://hub.docker.com/r/octoprint/octoprint))
  * Fluidd (via [GHCR](https://github.com/fluidd-core/fluidd/pkgs/container/fluidd))
  * Mainsail (via [GHCR](https://github.com/mainsail-crew/mainsail/pkgs/container/mainsail))
  * KlipperScreen

Depending on which Frontend you've chosen, moonraker will also be deployed.

## Getting started
The following Guide requires ``docker`` and ``docker compose`` on your machine.  
Follow the official Guides on how to get them up and running. 
* https://docs.docker.com/engine/install/ubuntu/
* https://docs.docker.com/compose/cli-command/#installing-compose-v2

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
Locate the ``webcam`` Service within ``docker-compose.override.yaml`` and update the ``device`` Section with the Device Name of your Webcam.  
In this example, the Webcam is using device ``/dev/video0``. Do not edit any other lines.
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
All Runtime Configs are stored within ``config`` of this Repo.  
* Update ``config/printer.cfg`` with your Klipper config, set the serial device and make sure to not remove the existing Macros as they are required by fluidd/mainsail. See [Klipper3d Docs](https://www.klipper3d.org/Config_Reference.html) for Reference
* Make sure to update ``cors_domains`` and ``trusted_clients`` within ``moonraker.cfg`` to secure your moonraker api from unwanted access. See [Moonraker Docs](https://moonraker.readthedocs.io/en/latest/configuration/) for Reference

### Starting the stack
There are currently 3 frontend Profiles to choose from, depending on the Web Frontend you'd like to use.
* fluidd
* mainsail
* octoprint

Starting the stack comes down to:
```
docker compose --profile <profile> up -d
```
e.g.
```
docker compose --profile fluidd up -d
```

Switching between profiles requires the whole stack to be torn down before starting another Frontend.  
Running two Frontends at the same time is currently not supported.
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

## Updating
Images are built daily and tagged with latest and the first seven chars of the commit-sha of the remote repo. 
Example: 

* ``mkuf/klipper:latest``
* ``mkuf/klipper:a33d069``

The ``latest`` Tag will point to a new Image within 24h.  
The SHA-Tag ``a33d069`` will remain and refers to [Klipper3d/klipper:a33d069](https://github.com/Klipper3d/klipper/commit/a33d0697b6438e362f0cf9d25e1e8358d331bf53)

Updating can be handled via docker-compose.  
docker-compose.yaml uses latest tags for all Images contained in this Repository.  
Compose will download all current Images and replace them when starting the stack again.  
Make sure to include _all_ profiles that you specified at stack startup when pulling images.  
```
docker compose --profile <profile> pull
docker compose --profile <profile> up -d
``` 

## Advanced Topics
### Serial device permissions
It may be necessary to change the permissions of your printers serial device.  
This is usually the case when you're on a non debian based distro which uses a different numerical groupid for the `dialout` group.  

Serial devices passed into the klipper container should be assigned to groupid `20` for the permissions to work within it.

This may be done by creating a udev rule on your host machine for your specific device, read up on how to do this on your specific OS.  
Usually you'll have to create a `*.rules` file in `/etc/udev/rules.d` and add a single line like this to it.  
Be sure to use your devices specific `idVendor` and `idProduct`, which can be found via `lsusb`.

```
ACTION=="add",SUBSYSTEM=="tty",ATTRS{idVendor}=="0000",ATTRS{idProduct}=="0000",GROUP="20"
```

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
To add a new Ustreamer Service, simply add the following snippet to ``docker-compose.override.yaml``.  
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
If you'd like to customize the provided Docker Images, you may edit the Dockerfiles within the ``docker/<service>`` Directory.  
Images are build in multiple stages, the final stage is called ``run``. Based on this, you can update Service definitions within ``docker-compose.override.yaml`` to build Images locally.

Example: Build Moonraker  
Update the ``image:`` name and add a ``build`` config:
```yaml
  moonraker:
    image: moonraker:latest
    build:
      context: docker/moonraker
      target: run
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
