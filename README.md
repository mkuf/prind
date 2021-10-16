## Building MCU Code
Build the Docker Image
```
docker build \
  --file klipper.Dockerfile \
  --target mcu \
  --tag klipper-mcu \
  .
```

Build the mcu binary.

This example mounts an existing build config at `klipper/.config`. One may want to initially create this file via `make menuconfig`
```
docker run \
  --rm \
  --volume /opt/docker-sparkcube/config/config.udoo:/opt/klipper/.config \
  --volume /opt/docker-sparkcube/out:/opt/klipper/out \
  --interactive \
  --tty \
  klipper-mcu \
    bash -c "cd /opt/klipper; make"
```
