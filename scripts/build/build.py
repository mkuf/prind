#!/usr/bin/env python3

## Prerequisites
## * user has read access to upstream repo
## * docker login for each repo was executed
## * qemu has been set up
## * docker buildx instance has been created and bootstrapped

import os
import re
import git
import sys
import yaml
import getpass
import logging
import argparse
import tempfile

from datetime import datetime, timezone
from python_on_whales import docker

# Parse arguments
parser = argparse.ArgumentParser(
  prog="Build",
  description="Build container images for prind"
)
parser.add_argument("app",help="App to build. Directory must be located at ./docker/<app>")
parser.add_argument("--backfill",type=int,default=3,help="Number of latest upstream git tags to build images for [default: 3]")
parser.add_argument("--registry",help="Where to push images to, /<app> will be appended")
parser.add_argument("--platform",action="append",default=["linux/amd64"],help="Platform to build for. Repeat to build a multi-platform image [default: linux/amd64]")
parser.add_argument("--push",action="store_true",default=False,help="Push image to registry [default: False]")
parser.add_argument("--dry-run",action="store_true",default=False,help="Do not actually build images [default: False]")
parser.add_argument("--force",action="store_true",default=False,help="Build images even though they exist in the registry [default: False]")
parser.add_argument("--version",help="Which upstream Ref to build. Will overwrite automatic Version extraction from upstream")
parser.add_argument("--upstream",help="Overwrite upstream Repo Url. Will skip Url extraction from Dockerfile")
parser.add_argument("--suffix",help="Suffix to add after the image tag. Skips the creation of the 'latest' tag")
parser.add_argument("--config",help="Path to the build.yaml file",default="scripts/build/build.yaml")
args = parser.parse_args()

#---
# Set up logging
logger = logging.getLogger('prind')
logger.setLevel(logging.DEBUG)

formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
ch = logging.StreamHandler()
ch.setFormatter(formatter)
logger.addHandler(ch)

#---
# Read config
with open(args.config,"r") as file:
  cfg = yaml.safe_load(file)

#---
# static definitions
context = "docker/" + args.app
dockerfile = context + "/Dockerfile"
build = {
  "upstream": {
    "url": None,
    "ref": None
  },
  "targets": [],
  "versions": {},
  "summary": {
    "success": [],
    "failure": [],
    "skipped": [],
    "ignored": []
  },
  "labels": {
    "org.prind.version": os.environ.get("GITHUB_SHA",(git.Repo(search_parent_directories=True)).head.object.hexsha),
    "org.prind.image.created": datetime.now(timezone.utc).astimezone().isoformat(),
    "org.prind.image.authors": os.environ.get("GITHUB_REPOSITORY_OWNER",getpass.getuser()),
    "org.prind.image.url": "{GITHUB_SERVER_URL}/{GITHUB_REPOSITORY}".format(**os.environ) if "GITHUB_REPOSITORY" in os.environ else "local",
    "org.prind.image.documentation": ("{GITHUB_SERVER_URL}/{GITHUB_REPOSITORY}/blob/{GITHUB_SHA}/docker/" + args.app + "/README.md").format(**os.environ) if "GITHUB_REPOSITORY" in os.environ else "local",
    "org.prind.image.source": ("{GITHUB_SERVER_URL}/{GITHUB_REPOSITORY}/blob/{GITHUB_SHA}/docker/" + args.app).format(**os.environ) if "GITHUB_REPOSITORY" in os.environ else "local",
  }
}

#---
# extract info from dockerfile
logger.info("Reading " + dockerfile)
with open(dockerfile) as file:
  for line in file:

    # upstream repository url
    repo = re.findall(r'ARG REPO.*', line)
    if repo:
      build["upstream"]["url"] = repo[0].split('=')[1]

    # upstream version
    ref = re.findall(r'ARG VERSION.*', line)
    if ref:
      build["upstream"]["ref"] = ref[0].split('=')[1]

    # build targets
    target = re.findall(r'FROM .* AS .*', line)
    if target:
      if not "AS build" in target[0]:
        build["targets"].append(target[0].split(' AS ')[-1])

if args.upstream:
  logger.warning("Upstream Repo has been overwritten to: " + args.upstream )
  build["upstream"]["url"] = args.upstream
else:
  logger.info("Found upstream repository: " + build["upstream"]["url"])

if len(build["targets"]) < 1:
  logger.error("No targets found. Nothing to build")
  sys.exit(1)
else:
  logger.info("Found docker targets: " + str(build["targets"]))

#---
# populate version dict
if args.version:
  # version from args
  logger.warning("Version '" + args.version + "' specified, skipping upstream lookup")
  build["versions"][args.version] = { "latest": True }
else:
  # extract info from upstream
  logger.info("Cloning Upstream repository")
  tmp = tempfile.TemporaryDirectory()
  upstream_repo = git.Repo.clone_from(build["upstream"]["url"], tmp.name)

  logger.info("Generating Versions from Upstream repository")
  try:
    ## latest
    latest_version = upstream_repo.git.describe("--tags")
  except:
    ## if latest does not exist, use VERSION from dockerfile
    logger.warning("Upstream has no tags, using " + build["upstream"]["ref"] + " as latest")
    latest_version = build["upstream"]["ref"]
  build["versions"][latest_version] = { "latest": True }

  ## tags
  upstream_repo_sorted_tags = upstream_repo.git.tag("-l", "--sort=v:refname").splitlines()
  upstream_repo_number_of_tags = len(upstream_repo_sorted_tags)

  if upstream_repo_number_of_tags < args.backfill:
    logger.warning("Requested backfill is higher than the number of upstream tags. Limiting backfill to " + str(upstream_repo_number_of_tags))
    backfill = upstream_repo_number_of_tags
  else:
    backfill = args.backfill

  for i in range(1,backfill+1):
    tag = upstream_repo_sorted_tags[-abs(i)]
    if tag not in build["versions"].keys():
      build["versions"][tag] = { "latest": False }

  tmp.cleanup()
  logger.info("Found versions: " + str(build["versions"]))

#---
# Build all targets for all versions
for version in build["versions"].keys():

  # Check if specific version is in ignore list
  if version in cfg["ignore"].get(args.app, []):
    logger.warning("Version " + version + " will be ignored as configured in " + args.config)
    build["summary"]["ignored"].append(version)

  else:
    for target in build["targets"]:

      # Create list of docker tags
      docker_image = "/".join(filter(None, (args.registry, args.app)))
      tags = [
        docker_image + ":" + (version if target == "run" else '-'.join([version, target])) + (f"_{args.suffix}" if args.suffix else ""),
        *(docker_image + (":latest" if target == "run" else '-'.join([":latest", target])) for _i in range(1) if build["versions"][version]["latest"] and not args.suffix),
      ]

      try:
        if args.force:
          logger.warning("Build is forced")
          raise
        else:
          # Check if the image already exists
          docker.buildx.imagetools.inspect(tags[0])
          logger.info("Image " + tags[0] + " exists, nothing to to.")
          build["summary"]["skipped"].append(tags[0])
      except:
        if args.dry_run:
          logger.debug("[dry-run] Would build " + tags[0])
        else:
          try:
            # Build if image does not exist
            logger.info("Building " + tags[0])
            stream = (
              docker.buildx.build(
                # Build specific
                context_path = context,
                build_args = {"REPO": build["upstream"]["url"], "VERSION": version},
                platforms = args.platform,
                target = target,
                push = args.push,
                tags = tags,
                labels = {
                  **build["labels"],
                  "org.prind.image.version": version
                },
                stream_logs = True
              )
            )

            for line in stream:
              logger.info("BUILD: " + line.strip())

            logger.info("Successfully built " + tags[0])
            build["summary"]["success"].append(tags[0])
          except:
            logger.critical("Failed to build " + tags[0])
            build["summary"]["failure"].append(tags[0])

logger.info("Build Summary: " + str(build["summary"]))
if len(build["summary"]["failure"]) > 0:
  sys.exit(1)
