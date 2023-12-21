#!/usr/bin/zsh

[[ $EUID -ne 0 ]] && echo "This script must be run as root." && exit 1

main() {

	select_docker_id() {

	  docker ps |\
	    fzf |\
	    cut -d' ' -f1
	}

	docker inspect "$(select_docker_id)" | jq
}

main
