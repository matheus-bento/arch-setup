#!/usr/bin/env bash

# Prints a message in green into stdout

info() {
    printf "\033[0;32m%b\033[0m\n" "$1"
}

# Applies a git patch. Used to add patches to suckless applications.
# Assumes you are running this function inside the target repo

apply-patch() {
    local PATCH_URL=$1
    local PATCH_NAME="$(echo "$PATCH_URL" | tr '/' '\n' | tail -1)"

    curl -O "$PATCH_URL"
    git apply "$PATCH_NAME"
    rm -v "./$PATCH_NAME"
}

# 1. Localization

info "Configuring localization"

# Configures the system to use brazilian portuguese as the system language
cat /etc/locale.gen | sed "s/#pt_BR.UTF-8/pt_BR.UTF-8/; \
                           s/#en_US.UTF-8/en_US.UTF-8/" > ./new-locale.gen
mv ./new-locale.gen /etc/locale.gen
locale-gen

printf "LANG=pt_BR.UTF-8\n\
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

echo "$HOSTNAME" > /etc/hostname

printf "127.0.0.1        localhost\n\
::1              localhost\n\
127.0.1.1        $HOSTNAME        localhost" > /etc/hosts

# 3. Bootloader installation

info "Installing bootloader"

pacman -S --noconfirm grub os-prober

# Checking if computer is booted on UEFI mode
if [[ ! -z "$(ls /sys/firmware/efi/efivars 2>/dev/null)" ]]; then
    info "System booted in UEFI mode"
    info "Installing GRUB for UEFI"

    pacman -S --noconfirm efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
else
    info "System booted in BIOS mode"
    info "Installing GRUB for BIOS"

    read -p "\033[0;32mType the disk on which the system was installed: (dev/sdX) \033[0m" DEVICE

    info "Installing GRUB on disk $DEVICE"

    grub-install --target=i386-pc "$DEVICE"
fi

# Due to having os-prober installed, GRUB will check for other operating systems
# installed on mounted disks and add them to the generated config.
grub-mkconfig -o /boot/grub/grub.cfg

# 4. User creation

info "Change the root password"
passwd

cat /etc/sudoers | sed 's/# %sudo/%sudo/' > ./new-sudoers
mv ./new-sudoers /etc/sudoers

read -p "Inform the user name: " USERNAME

if [[ -z "$(cat /etc/group | grep sudo)" ]]; then
    groupadd sudo
fi

useradd -m -G sudo "$USERNAME"

info "Change your user password"
passwd "$USERNAME"

# 5. GUI configuration

info "Setting up the GUI"

info "Installing Xorg"

pacman -S --noconfirm xorg xorg-xinit

USER_HOME="/home/$USERNAME"

# Copying the default xinitrc, removing the last 5 lines and replacing them
# with a call to execute dwm automatically on xorg initialization
cat /etc/X11/xinit/xinitrc | head -n -5 > "$USER_HOME/.xinitrc"
echo "exec dwm" >> "$USER_HOME/.xinitrc"

# Initializing xorg after logging in to the created user
printf "\nif [ -z \"\$DISPLAY\" ] && [ \"\$XDG_VTNR\" -eq 1 ]; then\n\
    exec startx\n\
fi\n" >> "$USER_HOME/.bash_profile"

info "Installing dwm"

git clone https://git.suckless.org/dwm "$USER_HOME/repo/suckless/dwm"
cd "$USER_HOME/repo/suckless/dwm"

apply-patch "https://dwm.suckless.org/patches/center_first_window/dwm-centerfirstwindow-6.2.diff"
apply-patch "https://dwm.suckless.org/patches/centretitle/dwm-centretitle-20200907-61bb8b2.diff"
apply-patch "https://dwm.suckless.org/patches/gaps/dwm-gaps-6.0.diff"

make install

info "Installing st"

git clone https://git.suckless.org/st "$USER_HOME/repo/suckless/st"
cd "$USER_HOME/repo/suckless/st"

apply-patch "https://st.suckless.org/patches/dracula/st-dracula-0.8.5.diff"
apply-patch "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.5.diff"
apply-patch "https://st.suckless.org/patches/scrollback/st-scrollback-reflow-0.8.5.diff"
apply-patch "https://st.suckless.org/patches/scrollback/st-scrollback-mouse-20220127-2c5edf2.diff"

make install

info "All suckless programs were clone into $USER_HOME/repo/suckless/\n\
In order to update those, just pull and install it again using make"

info "Installation complete. You can now restart the computer and login as $USERNAME"

