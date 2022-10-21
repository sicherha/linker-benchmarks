#!/bin/bash

set -eu

BASEDIR=$(cd "$(dirname "$0")" && pwd)

. "$BASEDIR/../params"

EXE_FILE=bin/clang-$(cat "$BASEDIR/version" | cut -d . -f 1)

mkdir -p "$OUTPATH"
cd "$BASEDIR/llvm-project/build"
command=$(sed -E 's|^/usr/lib64/ccache/||' < tools/clang/tools/driver/CMakeFiles/clang.dir/link.txt)

for linker in "${LINKERS[@]}"; do
  timefile=$OUTPATH/clang-time-$linker.txt
  sizefile=$OUTPATH/clang-size-$linker.txt
  rm -f "$timefile"

  for _ in $(seq $ITERATIONS); do
    # shellcheck disable=SC2086
    (cd tools/clang/tools/driver && command time -o "$timefile" -a -v $command "-fuse-ld=$linker")

    # Cool down
    sleep 8
  done

  stat "$EXE_FILE" > "$sizefile"
done

# shellcheck disable=SC2086
(cd tools/clang/tools/driver && command time -o "$OUTPATH/clang-time-mold-nofork.txt" -v $command "-fuse-ld=mold" -Wl,--no-fork)
