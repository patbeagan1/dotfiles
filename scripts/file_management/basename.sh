#!/usr/bin/env bash
# (c) 2022 Pat Beagan: MIT License
set -euo pipefail

echo "$1" | sed 's/^.*\///g'
