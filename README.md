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
  * Fluidd (via [Dockerhub](https://hub.docker.com/r/cadriel/fluidd))
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
The `scripts` directory contains a wrapper that can be used as an alias for `make`. After setting this alias, follow the Instructions on finding your printer, building and flashing the microcontroller found in the [Klipper Docs](https://www.klipper3d.org/Installation.html#building-and-flashing-the-micro-controller).  

Adapted from the official Docs, a generic Build would look like this.
```
alias make="./scripts/build-mcu.sh"

make menuconfig
make
make flash FLASH_DEVICE=/dev/serial/by-id/<my printer>
```

If your Board can be flashed via SD-Card, you may want to omit `make flash` and retrieve the `klipper.bin` from the `out` directory that is created by `make`. Follow your boards instructions on how to proceed with flashing via SD-Card.

### Add your Configuration to docker-compose.override.yaml
Locate the ``klipper`` Service within ``docker-compose.override.yaml`` and update the ``device`` Section with the Serial Port of your Printer.  
In this example, the Printer is using device ``/dev/ttymxc3``.
```yaml
  klipper:
    devices:
      - /dev/ttymxc3:/dev/ttymxc3
```

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
* Update config/printer.cfg with your Klipper config, make sure to not remove the existing Macros as they are required by fluidd/mainsail. See [Klipper3d Docs](https://www.klipper3d.org/Config_Reference.html) for Reference
* Make sure to update ``cors_domains`` and ``trusted_clients`` within ``moonraker.cfg`` to secure your moonraker api from unwanted access. See [Moonraker Docs](https://moonraker.readthedocs.io/en/latest/configuration/) for Reference

### Starting the stack
Currently, there are 3 Profiles to choose from, depending on the Web Frontend you'd like to use.
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

### KlipperScreen
KlipperScreen can be run from within a Docker Container.  
It requires you to set up a X11 Server on your machine that the Container can connect to.  

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
```
docker compose pull
docker compose --profile <profile> up -d
``` 

## Advanced Topics
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
      - "traefik.enable=true"
      - "traefik.http.services.webcam2.loadbalancer.server.port=8080"
      - "traefik.http.routers.webcam2.rule=PathPrefix(`/webcam2`)"
      - "traefik.http.routers.webcam2.entrypoints=web"
      - "traefik.http.middlewares.webcam2.stripprefix.prefixes=/webcam2"
      - "traefik.http.routers.webcam2.middlewares=webcam2"
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

Locate the `docker-compose.simulavr.yaml` in the repository and set the `VERSION` Build-Arg to any Git Reference from [Klipper3d/klipper](https://github.com/Klipper3d) that you would like the mcu code to be compatible with. 

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
  -f docker-compose.simulavr.yaml \
  up -d
```
