#!/bin/sh

set -u
set -e

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
    sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::once:/bin/login' ${TARGET_DIR}/etc/inittab || \
    sed -i '/starturus/a\
tty1::once:/bin/login -f urusapp # URUS APP user login' ${TARGET_DIR}/etc/inittab
fi

cp -f $BOARD_DIR/config-$BOARD_NAME.txt $BINARIES_DIR/rpi-firmware/config.txt
cp -f $BOARD_DIR/cmdline-$BOARD_NAME.txt $BINARIES_DIR/rpi-firmware/cmdline.txt
cp -f $BOARD_DIR/startapp.sh ${TARGET_DIR}/etc/profile.d/
