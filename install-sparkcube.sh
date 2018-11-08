#!/bin/bash
# This script installs Klipper on a Raspberry Pi machine running the
# OctoPi distribution.

repo="/opt/klipper-sparkcube"
klipper_user="octoprint"

PYTHONDIR="${repo}/klippy-env"

# Step 1: Install system packages
install_packages()
{
    # Packages for python cffi
    PKGLIST="python-virtualenv virtualenv python-dev libffi-dev build-essential"
    # kconfig requirements
    PKGLIST="${PKGLIST} libncurses-dev"
    # hub-ctrl
    #PKGLIST="${PKGLIST} libusb-dev"
    # AVR chip installation and building
    #PKGLIST="${PKGLIST} avrdude gcc-avr binutils-avr avr-libc"
    # ARM chip installation and building
    #PKGLIST="${PKGLIST} stm32flash libnewlib-arm-none-eabi"
    PKGLIST="${PKGLIST} libnewlib-arm-none-eabi"
    PKGLIST="${PKGLIST} gcc-arm-none-eabi binutils-arm-none-eabi"

    # Update system package info
    report_status "Running apt-get update..."
    apt-get update

    # Install desired packages
    report_status "Installing packages..."
    apt-get install --yes ${PKGLIST}
}

# Step 2: Create python virtual environment
create_virtualenv()
{
    report_status "Updating python virtual environment..."

    # Create virtualenv if it doesn't already exist
    [ ! -d ${PYTHONDIR} ] && virtualenv ${PYTHONDIR}

    # Install/update dependencies
    ${PYTHONDIR}/bin/pip install cffi==1.6.0 pyserial==3.2.1 greenlet==0.4.10
}

# Step 3: Install startup script config
install_systemd_unit()
{
    unitfile=/etc/systemd/system/klipper.service
    [ -f ${unitfile} ] && return

    report_status "Installing system start configuration..."
    cat > ${unitfile} <<EOF
[Unit]
Description=Klipper
After=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
RemainAfterExit=yes
User=${klipper_user}
ExecStart=${PYTHONDIR}/bin/python ${repo}/klipper/klippy/klippy.py ${repo}/sparkcube.cfg -l /var/log/klippy.log

EOF

    systemctl daemon-reload
    systemctl enable klipper.service
    systemctl start klipper.service
}

# Step 4: Start host software
start_software()
{
    report_status "Launching Klipper host software..."
    systemctl start klipper
}

# Helper functions
report_status()
{
    echo -e "\n\n###### $1"
}

# Force script to exit if an error occurs
set -e

# Find SRCDIR from the pathname of this script
SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"

# Run installation steps defined above
install_packages
create_virtualenv
install_systemd_unit
#start_software
