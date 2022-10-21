#!/bin/sh

set -e -u

docker build -t linker-benchmark .

mkdir -p .ccache .mozbuild
docker run -it --rm \
  --security-opt label=disable --userns=keep-id \
  -v "$PWD:/benchmarks:Z" \
  -v .ccache:/root/.ccache:Z \
  -w /benchmarks \
  linker-benchmark \
  "$@"
