#!/bin/bash

set -eu

BASEDIR=$(cd "$(dirname "$0")" && pwd)

. "$BASEDIR/../params"

SO_FILE=qtbase/lib/libQt6WebEngineCore.so.$(cat "$BASEDIR/version")

mkdir -p "$OUTPATH"
cd "$BASEDIR/qt5/build"
rm -f "$SO_FILE"
command=$(ninja -v "$SO_FILE" | grep clang | sed -E 's/^.*(clang.*)\s*&& :$/\1/')

for linker in "${LINKERS[@]}"; do
  timefile=$OUTPATH/qt-time-$linker.txt
  sizefile=$OUTPATH/qt-size-$linker.txt

  rm -f "$timefile"
  for _ in $(seq $ITERATIONS); do
    # shellcheck disable=SC2086
    command time -avo "$timefile" $command "-fuse-ld=$linker"

    # Cool down
    sleep 8
  done

  stat "$SO_FILE" > "$sizefile"
done

# shellcheck disable=SC2086
command time -o "$OUTPATH/qt-time-mold-nofork.txt" -v $command "-fuse-ld=mold" -Wl,--no-fork
