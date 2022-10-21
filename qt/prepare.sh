#!/bin/sh

set -eu

BASEDIR=$(cd "$(dirname "$0")" && pwd)

cd "$BASEDIR"
[ -d qt5 ] || git clone git://code.qt.io/qt/qt5.git
cd qt5
git fetch
git checkout "v$(cat "$BASEDIR/version")"
git submodule update
git submodule update --init --recursive qttools qtwebengine
perl init-repository || :

mkdir -p build
cd build
../configure -debug -platform linux-clang -submodules qtbase,qtshadertools,qtwebengine -ccache
cmake --build . --parallel
