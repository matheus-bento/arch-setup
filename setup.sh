#!/usr/bin/env bash

source ./globals.sh

function print-keymaps() {
	find /usr/share/kbd/keymaps/i386 -regex ".*\.map\.gz" | sed 's/[A-Za-z0-9\-]*\///g; s/\.map.\gz//' | sort
}

# 1. Localization

while true; do
	info "Choose your preferred system locale (type \"l\" to list available locales)"

	read LOCALE

	case $LOCALE in
		l)
			cat /usr/share/i18n/SUPPORTED | sed "s/#//g" | awk '{print $1}' | less
			;;
		*)
			[[ ! -z "$(grep "$LOCALE" /usr/share/i18n/SUPPORTED)" ]] && break;
			echo "Invalid locale"
			;;
	esac
done

cat /etc/locale.gen | sed "s/#$LOCALE/$LOCALE/" > ./new-locale.gen
mv ./new-locale.gen /etc/locale.gen

locale-gen

printf "LANG=$LOCALE" > /etc/locale.conf

while true; do
	info "Choose your preferred keyboard layout (type \"l\" to list available layouts)"

	read KEYMAP

	case $KEYMAP in
		l)
			print-keymaps | less
			;;
		*)
			[[ ! -z "$(print-keymaps | grep "$KEYMAP")" ]] && break;
			echo "Invalid keymap"
			;;
	esac
done

echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

# 2. Networking

info "Configuring networking"

pacman -S --noconfirm netctl dhcpcd

# Creating a profile from the provided example directory
cat /etc/netctl/examples/ethernet-dhcp | sed "s/#DHCPClient=dhcpcd/DHCPClient=dhcpcd/" > /etc/netctl/ethernet-dhcp
netctl enable ethernet-dhcp

HOSTNAME="archlinux.desktop"

echo "$HOSTNAME" > /etc/hostname

printf "127.0.0.1		localhost\n\
::1		localhost\n\
127.0.1.1		$HOSTNAME		localhost" > /etc/hosts

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

while true; do
	passwd
	[[ "$?" -eq 0 ]] && break
done

cat /etc/sudoers | sed 's/# %sudo/%sudo/' > ./new-sudoers
mv ./new-sudoers /etc/sudoers

info "Inform your new user name:"
read USERNAME

[[ -z "$(cat /etc/group | grep sudo)" ]] && groupadd sudo

useradd -m -G sudo "$USERNAME"

info "Change your user password"

while true; do
	passwd "$USERNAME"
	[[ "$?" -eq 0 ]] && break
done

USER_HOME="/home/$USERNAME"

# 5. GUI configuration

while true; do
	info "Choose your preferred GUI flavor (type \"l\" to list available flavors)"

	read FLAVOR

	case $FLAVOR in
		l)
			cat ./gui-flavors
			;;
		*)
			if [[ -z "$(awk "\$1 ~ /$FLAVOR/ { print \$1 }" ./gui-flavors)" ]]; then
				echo "Flavor \"$FLAVOR\" not available"
			else
				info "Setting up the GUI"
				bash "./$FLAVOR/setup.sh"

				break
			fi
			;;
	esac
done

info "Installation complete. You can now restart the computer and login as $USERNAME"

