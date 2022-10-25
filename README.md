# arch-setup
My arch linux setup script.

## Usage

Run setup.sh on chroot to perform the basic setup, after partitioning the disk and installing the system using pacstrap. After this, reboot the system, 
log into the created user and run xorg-setup.sh to configure Xorg keyboard and monitor settings.

## Dependencies

This script relies on packages from the base-devel group, run the scripts after installing the system using pacstrap.
