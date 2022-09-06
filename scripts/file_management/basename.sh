#!/usr/bin/env bash
set -euo pipefail

echo "$1" | sed 's/^.*\///g'
