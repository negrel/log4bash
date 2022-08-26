#!/usr/bin/env bash

set -eu

for f in test/*; do
  echo "executing $f..."
  $f
  echo -e "$f successfully executed.\n"
done
