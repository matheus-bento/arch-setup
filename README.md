# arch-setup
My arch linux setup script.

## Usage

Run setup.sh on chroot to perform the basic setup, after partitioning the disk and installing the system using pacstrap. After this, reboot the system, 
log in as the newly created user and run post-install.sh, located in the user's home directory, to make some extra environment configuration.

## Dependencies

This script relies on packages from the base-devel group, run the scripts after installing it using pacstrap.
