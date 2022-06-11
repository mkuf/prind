<p align=center><img src=img/prind-logo.png height=400px></p>

# prind
[![Image: Klipper](https://github.com/mkuf/prind/actions/workflows/klipper.yaml/badge.svg)](https://github.com/mkuf/prind/actions/workflows/klipper.yaml)
[![Image: Moonraker](https://github.com/mkuf/prind/actions/workflows/moonraker.yaml/badge.svg)](https://github.com/mkuf/prind/actions/workflows/moonraker.yaml)
[![Image: Mainsail](https://github.com/mkuf/prind/actions/workflows/mainsail.yaml/badge.svg)](https://github.com/mkuf/prind/actions/workflows/mainsail.yaml)
[![Image: Klipperscreen](https://github.com/mkuf/prind/actions/workflows/klipperscreen.yaml/badge.svg)](https://github.com/mkuf/prind/actions/workflows/klipperscreen.yaml)
[![Image: Ustreamer](https://github.com/mkuf/prind/actions/workflows/ustreamer.yaml/badge.svg)](https://github.com/mkuf/prind/actions/workflows/ustreamer.yaml)

prind allows you to run the Software for your 3D Printer in Docker containers.  
With a single Command, you can start up klipper and choose between multiple Frontends. 

Currently supported Frontends:
  * Octoprint (via [Dockerhub](https://hub.docker.com/r/octoprint/octoprint))
  * Fluidd (via [Dockerhub](https://hub.docker.com/r/cadriel/fluidd))
  * Mainsail
  * KlipperScreen

Depending on which Frontend you've chosen, moonraker will also be deployed.

## Getting started
The following Guide requires ``docker`` and ``docker compose`` on your machine.  
Follow the official Guides on how to get them up and running. 
* https://docs.docker.com/engine/install/ubuntu/
* https://docs.docker.com/compose/cli-command/#installing-compose-v2


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
    container_name: webcam
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

The Prid Logo should now be displayed on your screen.  
If this is not the case, check the scripts output for errors.  
Otherwise, proceed to start/update the Stack.

```
docker compose --profile fluidd --profile klipperscreen up -d
```

## Updating
Images are built daily and tagged with nightly and the first seven chars of the commit-sha of the remote repo. 
Example: 

* ``mkuf/klipper:nightly``
* ``mkuf/klipper:a33d069``

The ``Nightly`` Tag will point to a new Image within 24h.  
The SHA-Tag ``a33d069`` will remain and refers to [Klipper3d/klipper:a33d069](https://github.com/Klipper3d/klipper/commit/a33d0697b6438e362f0cf9d25e1e8358d331bf53)

Updating can be handled via docker-compose.  
docker-compose.yaml uses nightly tags for all Images contained in this Repository.  
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
    container_name: webcam2
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

### Building MCU Code
The multistage Image for Klipper contains a ``mcu`` target which is a Ubuntu Image with all requirements installed to compile the MCU Code for Klipper. 

Repace the serial port at '--device' with your MCUs Device.
Running the following command will execute
 * make menuconfig
 * make
 * make flash

This example mounts an existing build config at `klipper/.config`, preserves your build config (``klipper/.config``), creates a directory ``out`` in your current working directory, and flashes the mcu code onto your device. 

```
docker run \
  --rm \
  --volume $(pwd)/config/build.config:/opt/klipper/.config \
  --volume $(pwd)/out:/opt/klipper/out \
  --interactive \
  --tty \
  --device /dev/ttyUSB0:/dev/ttyUSB0 \
  mkuf/klipper:nightly-mcu \
    bash -c "cd /opt/klipper; make menuconfig && make && make flash"
```
If you are trying to flash a Creality/SKR board with an SD card slot, you may find it easier to just flash a .bin file. In order to do this, remove `make flash` from bash line of the docker run command. It would look like: `bash -c "cd /opt/klipper; make menuconfig && make && make flash` You will be able to retrieve the .bin file from the `out` directory. (e.g. If you have the Ender 3 V2, you would wipe an SD card and format as FAT or FAT32, copy the .bin file to the SD card, and power the board waiting 30sec each time.)

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

This example builds the mcu code from [Klipper3d/klipper:d75154d](d75154d695efb1338cbfff061d226c4f384d127b)
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
