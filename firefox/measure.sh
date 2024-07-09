#!/bin/bash

set -eu

BASEDIR=$(cd "$(dirname "$0")" && pwd)

. "$BASEDIR/../params"

mkdir -p "$OUTPATH"
cd "$BASEDIR/mozilla-release/obj-x86_64-pc-linux-gnu/toolkit/library/build"
LIBRARY=../../../dist/bin/libxul.so
rm -f "$LIBRARY"
command=$(make "$LIBRARY" | grep clang | sed -E 's|^/usr/bin/ccache\s+||')

for linker in "${LINKERS[@]}"; do
  timefile=$OUTPATH/firefox-time-$linker.txt
  sizefile=$OUTPATH/firefox-size-$linker.txt

  rm -f "$timefile"
  for _ in $(seq $ITERATIONS); do
    # shellcheck disable=SC2086
    command time -o "$timefile" -a -v $command "-fuse-ld=$linker"

    # Cool down
    sleep 8
  done

  stat "$LIBRARY" > "$sizefile"
done

# shellcheck disable=SC2086
command time -o "$OUTPATH/firefox-time-mold-nofork.txt" -v $command "-fuse-ld=mold" -Wl,--no-fork
