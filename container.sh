#!/bin/sh

set -e -u

docker build -t linker-benchmark .

mkdir -p .ccache .mozbuild
PODMAN_USERNS=keep-id docker run -it --rm \
  --security-opt label=disable \
  -v "$PWD:/benchmarks:Z" \
  -v .ccache:/root/.ccache:Z \
  -w /benchmarks \
  linker-benchmark \
  "$@"
