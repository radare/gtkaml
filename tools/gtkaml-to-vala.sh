#!/bin/sh
set -eu

gtkamlc=$1
input=$2
output=$3
shift 3

outdir=$(dirname "$output")
mkdir -p "$outdir"

work_input="$outdir/$(basename "$input")"
work_base=${work_input%.*}
work_vala="${work_base}.vala"
work_gtkaml="${work_base}.gtkaml"

cp "$input" "$work_input"
rm -f "$work_vala"
if [ "$work_gtkaml" != "$work_input" ]; then
  rm -f "$work_gtkaml"
fi

"$gtkamlc" "$@" -V "$work_input"

mv "$work_vala" "$output"
rm -f "$work_input"
if [ "$work_gtkaml" != "$work_input" ]; then
  rm -f "$work_gtkaml"
fi
