#!/bin/bash
#
# Provides a distro-agnostic interface for working with the system's default package manager.


# TODO:
# package-manager::update () {
# }


package-manager::upgrade () {
    if [[ $# -ne 1 ]]; then
        echo "One argument required! Exiting."
    else
        if [[ "$1" == "apt" ]]; then
            if [[ $(apt-get update -qq) -eq 0 ]]; then
	        	echo "Upgrading packages..."
                # note: NEEDRESTART_SUSPEND=1 is required in Ubuntu 22.04 LTS in order to prevent a 
                # prompt which asks the user which service(s) should be restarted, if any.
	        	# NEEDRESTART_SUSPEND=1 apt-get upgrade -qq -y
	        	sudo apt-get upgrade -qq -y
	        fi
        elif [[ "$1" == "pacman" ]]; then
            if [[ $(pacman -Syq) -eq 0 ]]; then
	        	echo "Upgrading packages..."
                # the `--needed` flag maybe makes this conditional unnecessary?
                sudo pacman -Syuq --needed --noconfirm
	        fi
        else
            echo "Package manager $1 is not supported!"
        fi
    fi
}


package-manager::get () {
    local DISTRO="$1"
    if [[ "$DISTRO" == *"Arch"* ]]; then
        echo "pacman"
    elif [[ "$DISTRO" == *"Debian"* ]] || [[ "$DISTRO" == *"Ubuntu"* ]]; then
        echo "apt"
    else
        echo "$DISTRO not yet supported!"
    fi
}


package-manager::main () {
    local THIS_FILE=$(realpath "$0")
    local THIS_DIR=$(realpath $(dirname "$THIS_FILE"))
    # echo "This file: $THIS_FILE"
    # echo "This dir: $THIS_DIR"

    local DOTFILES=$(realpath $(dirname $(realpath $(dirname "$THIS_DIR"))))
    local GET_DISTRO_SCRIPT=$(realpath "$DOTFILES/_utils/installs/unix/linux/utils/get-distro.sh")
    local DISTRO=$($GET_DISTRO_SCRIPT)
    # echo "$DISTRO"
    local PACKAGE_MANAGER=$(package-manager::get "$DISTRO")
    echo "$PACKAGE_MANAGER"

    # TODO: replace this with proper CLI flags.
    # if [[ "$1" == "install" ]]; then
        # package-manager::install "$DISTRO"
    # if [[ "$1" == "update" ]]; then
        # package-manager::update "$DISTRO"
    if [[ "$1" == "upgrade" ]]; then
        package-manager::upgrade "$PACKAGE_MANAGER"
    else
        "$1 is not a valid action! Exiting."
    fi
}



if [[ $(uname) != "Linux" ]]; then
    echo "$(uname) not supported! This only runs on Linux. Exiting."
else
    if [[ $# -ne 1 ]]; then
        echo "One argument required! Exiting."
    else
        package-manager::main "$1"
    fi
fi

