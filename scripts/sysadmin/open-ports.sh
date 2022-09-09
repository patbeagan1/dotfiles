#!/usr/bin/env bash

open-ports () {
	sudo lsof -i -n -P | grep LISTEN
}
open-ports
trackusage.sh "$0"