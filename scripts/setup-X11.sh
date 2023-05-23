## This script installs X11 and sets up a xinit service
## xterm is running in foreground until the klipperscreen
## container connects to the xserver

#!/bin/bash

set -xe

## Name of the new user
USER=screen

## Create User
adduser --system --disabled-password --shell /bin/bash ${USER}
usermod -a -G tty ${USER}

## Install Packages
apt update
apt install -y feh xterm xinit xinput xserver-xorg xserver-xorg-legacy x11-xserver-utils xserver-xorg-video-fbdev

## Allow any User to start X
if [ -f /etc/X11/Xwrapper.config ]; then
  sed -i 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config
else
  cat <<EOF > /etc/X11/Xwrapper.config
needs_root_rights=yes
allowed_users=anybody
EOF
fi

## Create the xinit systemd service
cat <<EOF > /etc/systemd/system/xinit.service
[Unit]
Description=Autologin to X
After=systemd-user-sessions.service

[Service]
User=${USER}
ExecStart=/usr/bin/xinit /usr/bin/feh -FZY $(pwd)/img/splashscreen-1080p-dark.png

[Install]
WantedBy=multi-user.target
EOF

## Reload, enable and start the xinit service
systemctl daemon-reload
systemctl enable xinit.service
systemctl start xinit