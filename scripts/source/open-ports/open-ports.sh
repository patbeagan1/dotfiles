#!/usr/bin/env bash
# (c) 2022 Pat Beagan: MIT License

open-ports () {
	sudo lsof -i -n -P | grep LISTEN
}
open-ports
trackusage.sh "$0"