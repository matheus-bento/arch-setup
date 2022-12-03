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
	patch -i "$PATCH_NAME"
	rm -v "./$PATCH_NAME"
}

# Arguments passed on the script call
SCRIPT_DIR=$1
USERNAME=$2
USER_HOME=$3

info "Installing Xorg"

pacman -S --noconfirm xorg xorg-xinit gnu-free-fonts

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
apply-patch "https://dwm.suckless.org/patches/uselessgap/dwm-uselessgap-20211119-58414bee958f2.diff"

cp "$SCRIPT_DIR/dwm/config/dwm/config.h" "$USER_HOME/repo/suckless/dwm"

make install

info "Installing st"

git clone https://git.suckless.org/st "$USER_HOME/repo/suckless/st"
cd "$USER_HOME/repo/suckless/st"

apply-patch "https://st.suckless.org/patches/dracula/st-dracula-0.8.5.diff"
apply-patch "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.5.diff"
apply-patch "https://st.suckless.org/patches/scrollback/st-scrollback-reflow-0.8.5.diff"
apply-patch "https://st.suckless.org/patches/scrollback/st-scrollback-mouse-20220127-2c5edf2.diff"

cp "$SCRIPT_DIR/dwm/config/st/config.h" "$USER_HOME/repo/suckless/st"

make install

# Changing ownership of everything in the user home directory to the newly created user
chown -R "$USERNAME" "$USER_HOME"
chgrp -R "$USERNAME" "$USER_HOME"

info "All suckless programs were clone into $USER_HOME/repo/suckless/\n\
In order to update those, just pull and install it again using make"

# 6. Applying utilitary scripts

info "Moving utilitary scripts into /usr/local/bin"

sudo cp -v "$SCRIPT_DIR/dwm/bin/"* /usr/local/bin/

# Moving the post install script to the new user's home
cp "$SCRIPT_DIR/dwm/post-install.sh" "$USER_HOME"

info "After rebooting, run post-install.sh located at $USER_HOME to make some aesthetic post install settings"

