#!/bin/bash

set -eu

. params

if [ $# -gt 0 ]; then
  PROJECTS=("$@")
fi

for project in "${PROJECTS[@]}"; do
  "$project/prepare.sh"
done
