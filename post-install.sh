#!/usr/bin/env bash

# This script runs some extra configurations for the graphic environment
# after the applications have been installed by setup.sh

# Prints a message in green into stdout

info() {
    printf "\033[0;32m%b\033[0m\n" "$1"
}

while true; do
    info "Choose your preferred keyboard layout (type \"l\" to list available layouts)"

    read LAYOUT

    case $LAYOUT in
        l)
            localectl list-x11-keymap-layouts
            ;;
        *)
            [ ! -z "$(localectl list-x11-keymap-layouts | grep -x "$LAYOUT")" ] && break;
            echo "Invalid layout"
            ;;
    esac
done

# Configuring Xorg to use the brazilian keyboard layout by default
printf "Section \"InputClass\"\n\
        Identifier \"system-keyboard\"\n\
        Option \"XkbLayout\" \"$LAYOUT\"\n\
EndSection\n" | sudo tee /etc/x11/xorg.conf.d/00-keyboard.conf 1>/dev/null

info "Configuring monitor resolution"

# Configuring the connected monitor to use 1920x1080
printf "Section \"Monitor\"\n\
        Identifier \"$(xrandr | grep "connected" -m 1 | awk -F'[ ]' '{print $1}')\"\n\
	$(cvt 1920 1080)\n\
	Option \"PreferredMode\" $(cvt 1920 1080 | tail -1 | awk '{print $2}')\n\
EndSection\n" | sudo tee /etc/X11/xorg.conf.d/10-monitor.conf 1>/dev/null

info "Xorg mouse and monitor configuration done"

info "Installing yay"

git clone https://aur.archlinux.org/yay ~/repo/aur/yay
cd ~/repo/aur/yay

makepkg -si

info "Installing some extra fonts"

yay -S --noconfirm nerd-fonts-fira-code

info "Post install configuration done. Restart to apply those changes"

