#!/bin/bash

set -eu

. params

if [ $# -gt 0 ]; then
  PROJECTS=("$@")
fi

for project in "${PROJECTS[@]}"; do
  "$project/measure.sh"
done

ld.bfd --version | grep 'GNU ld version' | sed -E 's/^GNU ld version ([0-9]+\.[0-9]+).*$/\1/' > "$OUTPATH/version-bfd.txt"
ld.gold --version | grep 'GNU gold (version' | sed -E 's/^GNU gold \(version ([0-9]+\.[0-9]+).*$/\1/' > "$OUTPATH/version-gold.txt"
ld.lld --version | sed -E 's/^LLD ([0-9]+\.[0-9]*\.[0-9]+)\s+.*$/\1/' > "$OUTPATH/version-lld.txt"
ld.mold --version | sed -E 's/^mold ([0-9]+\.[0-9]*(\.[0-9]+)?)\s+.*$/\1/' > "$OUTPATH/version-mold.txt"
