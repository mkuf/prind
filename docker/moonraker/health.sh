#!/bin/bash

serverinfo=$(curl -s localhost:7125/server/info)

klippy_connected=$(echo -n ${serverinfo} | jq -r .result.klippy_connected)
klippy_state=$(echo -n ${serverinfo} | jq -r .result.klippy_state)
failed_components=$(echo -n ${serverinfo} | jq -r .result.failed_components[] | wc -l)

if [ "$klippy_connected" == "true" ] \
&& [ "$klippy_state" == "ready" ] \
&& [ $failed_components -eq 0 ]; then
  ## moonraker is up and connected to klippy
  exit 0
else
  ## moonraker started w/ failed components and/or is not connected to klippy
  exit 1
fi