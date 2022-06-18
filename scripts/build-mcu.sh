#!/bin/bash

docker compose -f docker-compose.mcu.yaml run --rm make "${@}"
