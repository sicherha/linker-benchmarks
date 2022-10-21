#!/bin/sh

set -eu

OUTFILE=README.md

{
cat << EOF
# Linker benchmarks
## Test system
EOF

grep -E '^model name' /proc/cpuinfo \
     | uniq \
     | sed -E 's/model name\s+:\s+/* /'

ramKiB=$(grep -E '^MemTotal:' /proc/meminfo \
         | sed -E 's/^MemTotal:\s+([0-9]+)\s+kB$/\1/')
python3 -c "import math; print(f'* {math.ceil($ramKiB / 1048576)} GiB RAM')"

lshw -class storage -short 2> /dev/null \
     | grep -E '^\S+\s+\S+\s+storage+\s+\S+' \
     | sed -E 's/^\S+\s+\S+\s+storage\s+/* /'

cat << EOF

## Results
### Memory use
![Memory use](rss.svg)

### Link times
![Link times](link-times.svg)
EOF
} > "$OUTFILE"
