#!/bin/bash

set -x

docker compose -f docker-compose.mcu.yaml run --rm make "${@}"
