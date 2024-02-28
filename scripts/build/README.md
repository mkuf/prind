# build.py
This script is used to build multi platform images provided by prind and upload them to the registry. 

## Local usage
### Multi-Platform Requirements
To build multi-platform images on your local machine, run the follwing commands to set up qemu and a docker buildx instance. This is not necessary if you only want to build images for the platform you're currently running on.

```bash
apt install qemu-user-static
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --use --name cross
docker buildx inspect --bootstrap
```
### Running the build script
Set up a venv and install requirements.  
All commands are run from the root of the repository
```bash
python3 -m venv venv
venv/bin/pip install -r scripts/build/requirements.txt
```

Usage description:
```bash
usage: Build [-h] [--backfill BACKFILL] [--registry REGISTRY] [--platform PLATFORM] [--push] [--dry-run] [--force]
             app

Build container images for prind

positional arguments:
  app                  App to build. Directory must be located at ./docker/<app>

options:
  -h, --help           show this help message and exit
  --backfill BACKFILL  Number of latest upstream git tags to build images for [default: 3]
  --registry REGISTRY  Where to push images to, /<app> will be appended
  --platform PLATFORM  Platform to build for. Repeat to build a multi-platform image [default: linux/amd64]
  --push               Push image to registry [default: False]
  --dry-run            Do not actually build images [default: False]
  --force              Build images even though they exist in the registry [default: False]
```