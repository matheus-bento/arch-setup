#!/usr/bin/env bash

# Prints a message in green into stdout

info() {
	printf "\033[0;32m%b\033[0m\n" "$1"
}

# Variable contaning the setup script directory
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]")" && pwd)"

# Username set by setup.sh
USERNAME=""

# User home directory set by setup.sh
USER_HOME=""

