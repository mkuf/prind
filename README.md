[![Image: Klipper](https://github.com/mkuf/prind/actions/workflows/klipper.yaml/badge.svg)](https://github.com/mkuf/prind/actions/workflows/klipper.yaml)
[![Image: Moonraker](https://github.com/mkuf/prind/actions/workflows/moonraker.yaml/badge.svg)](https://github.com/mkuf/prind/actions/workflows/moonraker.yaml)
[![Image: Mainsail](https://github.com/mkuf/prind/actions/workflows/mainsail.yaml/badge.svg)](https://github.com/mkuf/prind/actions/workflows/mainsail.yaml)
[![Image: Ustreamer](https://github.com/mkuf/prind/actions/workflows/ustreamer.yaml/badge.svg)](https://github.com/mkuf/prind/actions/workflows/ustreamer.yaml)

# prind

prind allows you to run the Software for your 3D Printer in Docker containers.  
With a single Command, you can start up klipper and choose between multiple Webfrontends. 

Currently supported Frontends:
  * Octoprint (via [Dockerhub](https://hub.docker.com/r/octoprint/octoprint))
  * Fluidd (via [Dockerhub](https://hub.docker.com/r/cadriel/fluidd))
  * Mainsail

Depending on which Frontend you've chosen, moonraker will also be deployed.


## Getting started

The following Guide require ``docker`` and ``docker compose`` on your machine.  
Follow the official Guides on how to get them up and running. 
* https://docs.docker.com/engine/install/ubuntu/
* https://docs.docker.com/compose/install/


### Add your Configuration to docker-compose.yaml

Locate the ``klipper`` Service within ``docker-compose.yaml`` and update the ``device`` Section with the Serial Port of your Printer.  
In this example, the Printer is using device ``/dev/ttymxc3``. Do not edit any other lines.
```
  klipper:
    <<: *klipper-svc
    volumes:
      - ./config:/opt/cfg
      - run:/opt/run
      - gcode:/opt/gcode
    devices:
      - /dev/ttymxc3:/dev/ttymxc3
    profiles:
      - fluidd
      - mainsail
```

Locate the ``ustreamer`` Service within ``docker-compose.yaml`` and update the ``device`` Section with the Device Name of your Webcam.  
In this example, the Webcam is using device ``/dev/video0``. Do not edit any other lines.
```
  ustreamer:
    <<: *ustreamer-svc
    container_name: ustreamer
    devices:
      - /dev/video0:/dev/webcam
    labels:
      - "traefik.enable=true"
      - "traefik.http.services.ustreamer.loadbalancer.server.port=8080"
      - "traefik.http.routers.ustreamer.rule=PathPrefix(`/stream`)"
      - "traefik.http.routers.ustreamer.entrypoints=web"
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
Within docker-compose.yaml commands are already set, you may update them to fit your needs. 
Example from service Klipper:
```
  command:
    - "-I"
    - "run/klipper.tty"
    - "-a"
    - "run/klipper.sock"
    - "cfg/printer.cfg"
```

### Multiple Webcams
The Ustreamer Service is already templated to be easily reused for multi-webcam Setups.  
To add a new Ustreamer Service, simply add the following snippet to ``docker-compose.yaml``.  
Notice, that all service names, container names and traefik labels need to be unique. 
Hence replace webcam2 with webcam3 and so on for every webcam you add and update the physical device that gets passed to the container.
```
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
```

### Building Docker images locally
If you'd like to customize the provided Docker Images, you may edit the Dockerfiles within the ``docker/<service>`` Directory.  
Images are build in multiple stages, the final stage is called ``run``. Based on this, you can update Service definitions within ``docker-compose.yaml`` to build Images locally.

Example: Build Moonraker  
Update the ``image:`` name and add a ``build`` config:
```
  moonraker:
    image: moonraker:latest
    build:
      context: docker/moonraker
      target: run
```

### Building MCU Code
The multistage Image for Klipper contains a ``mcu`` target which is a Ubuntu Image with all requirements installed to compile the MCU Code for Klipper. 

This example mounts an existing build config at `klipper/.config`, preserves your build config (``klipper/.config``) and creates a directory ``out`` in your current working directory, where you'll find the compiled Binaries. 
```
docker run \
  --rm \
  --volume $(pwd)/config/build.config:/opt/klipper/.config \
  --volume $(pwd)/out:/opt/klipper/out \
  --interactive \
  --tty \
  mkuf/klipper:nightly-mcu \
    bash -c "cd /opt/klipper; make menuconfig && make"
```
