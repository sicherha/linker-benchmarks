#!/bin/sh

set -eu

BASEDIR=$(cd "$(dirname "$0")" && pwd)

cd "$BASEDIR"
[ -d mozilla-release ] || hg clone https://hg.mozilla.org/releases/mozilla-release
cd mozilla-release
hg pull
hg checkout "FIREFOX_$(sed 's/\./_/g' < "$BASEDIR/version")_RELEASE"

cp "$BASEDIR/mozconfig" .
./mach --no-interactive bootstrap --application-choice 'Firefox for Desktop' --no-system-changes
./mach build
