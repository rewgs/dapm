#!/bin/bash
#
# Provides a distro-agnostic interface for working with the system's default package manager.


# TODO: this is old code from another script, adapt for this one.
# install_packages () {
#     this_dir="$1"
#     . "$this_dir/distros.sh"

#     cd "$this_dir" || return
#     package_manager=$(get_package_manager "$(get_distro)" )
#     # echo "$distro uses package manager $package_manager"
#     update_packages "$package_manager"

#     echo "Installing packages..."
#     if [[ "$package_manager" == "apt" ]]; then
#         . packages/apt_packages.sh
#         for p in "${packages[@]}"; do
#             # note: NEEDRESTART_SUSPEND=1 is required in Ubuntu 22.04 LTS in order to prevent a 
#             # prompt which asks the user which service(s) should be restarted, if any.
#             # NEEDRESTART_SUSPEND=1 apt-get install -y "$a"
#             sudo apt-get install -y "$p"
#     	        # > /dev/null 2> /dev/null # for some reason, `&> /dev/null` isn't silent, but this is
#         done

#         for p in "${third_party_ppas[@]}"; do
#             sudo add-apt-repository ppa:"$p"
#         done

#         update_packages "$package_manager"

#         for p in "${ppa_packages[@]}"; do
#             sudo apt-get install -y "$p"
#         done

#     elif [[ "$package_manager" == "pacman" ]]; then
#         local AUR_HELPER="paru"
#         . packages/pacman_packages.sh
#         for p in "${packages[@]}"; do
#             # `pacman -Q` queries the installed local package database; `-i` returns information on the package.
#             # If exit code is 0, package is installed; otherwise, it's not.
#             if [[ ! $(pacman -Qi "$p") ]]; then
#                 sudo pacman -Syuq --noconfirm "$p"
#             fi
#         done

#         # TODO: check if $AUR_HELPER is installed; if not, install before running this
#         echo "Installing packages via the AUR..."
#         for p in "${aur_packages[@]}"; do
#             sudo "$AUR_HELPER" -Syuq --noconfirm "$p"
#         done
#     else
#         echo "Package manager $package_manager is not supported!"
#     fi

#     echo "Package manager basic installations complete!"
# }


dapm::update () {
    if [[ $# -ne 1 ]]; then
        echo "One argument required! Exiting."
    else
        if [[ "$1" == "apt" ]]; then
            sudo apt-get update
        elif [[ "$1" == "pacman" ]]; then
            sudo pacman -Syq
        else
            echo "Package manager $1 is not supported!"
        fi
    fi
}


dapm::upgrade () {
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


dapm::get-package-manager () {
    local DISTRO="$1"
    if [[ "$DISTRO" == *"Arch"* ]]; then
        echo "pacman"
    elif [[ "$DISTRO" == *"Debian"* ]] || [[ "$DISTRO" == *"Ubuntu"* ]]; then
        echo "apt"
    else
        echo "$DISTRO not yet supported!"
    fi
}


dapm::get-distro () {
    ( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1
}


dapm::main () {
    local DISTRO=$(dapm::get-distro)
    echo "Distro: $DISTRO"
    local PACKAGE_MANAGER=$(dapm::get-package-manager "$DISTRO")
    echo "Package manager: $PACKAGE_MANAGER"

    # TODO: replace this block with proper CLI flags.

    # TODO: install() function
    if [[ "$1" == "install" ]]; then
        echo "Function not yet written"
        # dapm::install "$PACKAGE_MANAGER"
    elif [[ "$1" == "update" ]]; then
        dapm::update "$PACKAGE_MANAGER"
    elif [[ "$1" == "upgrade" ]]; then
        dapm::upgrade "$PACKAGE_MANAGER"
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
        dapm::main "$1"
    fi
fi
