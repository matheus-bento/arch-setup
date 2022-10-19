#!/usr/bin/env bash

# Prints a message in green into stdout

info() {
    printf "\033[0;32m%b\033[0m\n" "$1"
}

# 1. Localization

info "Configuring localization"

# Configures the system to use brazilian portuguese as the system language
cat /etc/locale.gen | sed "s/#pt_BR.UTF-8/pt_BR.UTF-8/; \
                           s/#en_US.UTF-8/en_US.UTF-8/" > ./new-locale.gen
mv ./new-locale.gen /etc/locale.gen
locale-gen

echo -e "LANG=pt_BR.UTF-8\n\
LC_MESSAGES=en_US.UTF-8" > /etc/locale.conf

# Configures the system to use the abnt2 keyboard layout
echo "KEYMAP=br-abnt2" > /etc/vconsole.conf

# 2. Networking

info "Configuring networking"

pacman -S --noconfirm netctl dhcpcd

# Creating a profile from the provided example directory
cat /etc/netctl/examples/ethernet-dhcp | sed "s/#DHCPClient=dhcpcd/DHCPClient=dhcpcd/" > /etc/netctl/ethernet-dhcp
netctl enable ethernet-dhcp

HOSTNAME="archlinux.desktop"

cat "$HOSTNAME" > /etc/hostname

cat "127.0.0.1        localhost\n\
::1              localhost\n\
127.0.1.1        $HOSTNAME        localhost" > /etc/hosts

