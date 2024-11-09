#!/bin/bash

state=$(curl -s localhost:8080/state)
ok=$(echo $state | jq -r .ok)
online=$(echo $state | jq -r .result.source.online)

if [ "$ok" == "true" ] && [ "$online" == "true" ]; then
  ## ustreamer is ok and source is online
  exit 0
else
  ## ustreamer is not ok or source is not online
  exit 1
fi