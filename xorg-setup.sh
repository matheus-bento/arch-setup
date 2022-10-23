#!/usr/bin/env bash

# Prints a message in green into stdout

info() {
    printf "\033[0;32m%b\033[0m\n" "$1"
}

info "Configuring keyboard layout"

# Configuring Xorg to use the brazilian keyboard layout by default
printf "Section \"InputClass\"\n\
        Identifier \"system-keyboard\"\n\
        Option \"XkbLayout\" \"br\"\n\
EndSection" > /etc/X11/xorg.conf.d/00-keyboard.conf

info "Configuring monitor resolution"

# Configuring the connected monitor to use 1920x1080
printf "Section \"Monitor\"\n\
        Identifier \"$(xrandr | grep "connected" -m 1 | awk -F'[ ]' '{print $1}')\"\n\
	$(cvt 1920 1080)\n\
	Option \"PreferredMode\" $(cvt 1920 1080 | tail -1 | awk '{print $2}')\n\
EndSection" > /etc/X11/xorg.conf.d/10-monitor.conf

info "Xorg mouse and monitor configuration done. Reboot your computer to apply those changes"
