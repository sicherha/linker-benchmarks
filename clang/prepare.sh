#!/bin/sh

set -eu

BASEDIR=$(cd "$(dirname "$0")" && pwd)

cd "$BASEDIR"
[ -d llvm-project ] || git clone https://github.com/llvm/llvm-project.git
cd llvm-project
git fetch
git checkout "llvmorg-$(cat "$BASEDIR/version")"

mkdir -p build
cd build
CC=clang CXX=clang++ cmake -DCMAKE_BUILD_TYPE=Debug -DLLVM_CCACHE_BUILD=ON -DLLVM_ENABLE_PROJECTS=clang -G "Unix Makefiles" ../llvm
make -j4
