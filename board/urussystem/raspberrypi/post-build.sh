#!/bin/sh

set -u
set -e

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"

URUS_INITSRC=$BOARD_DIR/S30psplash
URUS_INITTGT=${TARGET_DIR}/etc/init.d/

URUSX_BINSRC=$BOARD_DIR/urusx
URUSX_BINTGT=${TARGET_DIR}/usr/bin/

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
    sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

#if [ -e ${TARGET_DIR}/etc/inittab ]; then
#    grep -qE '^tty1::once:/bin/login' ${TARGET_DIR}/etc/inittab || \
#    sed -i '/starturus/a\
#tty1::once:/bin/login -f urusapp # URUS APP user login' ${TARGET_DIR}/etc/inittab
#fi

cp -f $BOARD_DIR/config-$BOARD_NAME.txt $BINARIES_DIR/rpi-firmware/config.txt
cp -f $BOARD_DIR/cmdline-$BOARD_NAME.txt $BINARIES_DIR/rpi-firmware/cmdline.txt
cp -f $BOARD_DIR/startapp.sh ${TARGET_DIR}/etc/profile.d/
cp -f $BOARD_DIR/urus_srvmode ${TARGET_DIR}/sbin/

cp -f $URUSX_BINSRC $URUSX_BINTGT
cp -f $URUS_INITSRC $URUS_INITTGT

mkdir -p $BINARIES_DIR/initramfs/bin
mkdir -p $BINARIES_DIR/initramfs/sbin
mkdir -p $BINARIES_DIR/initramfs/lib
#mkdir -p $BINARIES_DIR/initramfs/usr/lib
mkdir -p $BINARIES_DIR/initramfs/usr/bin
mkdir -p $BINARIES_DIR/initramfs/usr/sbin

cp -rf system/skeleton/* $BINARIES_DIR/initramfs/
find $BINARIES_DIR/initramfs/ -name ".empty" | xargs rm -rf

cp -f $BOARD_DIR/urus_srvmode $BINARIES_DIR/initramfs/sbin/
cp -f $BOARD_DIR/init $BINARIES_DIR/initramfs/

cp -Hf ${TARGET_DIR}/sbin/resize2fs $BINARIES_DIR/initramfs/sbin/
cp -Hf ${TARGET_DIR}/sbin/dosfsck $BINARIES_DIR/initramfs/sbin/
cp -Hf ${TARGET_DIR}/sbin/e2fsck $BINARIES_DIR/initramfs/sbin/
cp -Hf ${TARGET_DIR}/sbin/fsck $BINARIES_DIR/initramfs/sbin/
cp -Pf ${TARGET_DIR}/sbin/fsck.* $BINARIES_DIR/initramfs/sbin/

cp -Hf ${TARGET_DIR}/usr/sbin/parted $BINARIES_DIR/initramfs/sbin/
cp -f ${TARGET_DIR}/bin/busybox $BINARIES_DIR/initramfs/bin/
cp -f ${TARGET_DIR}/etc/fstab $BINARIES_DIR/initramfs/etc/

cp -Pf ${TARGET_DIR}/lib32 $BINARIES_DIR/initramfs/
cp -Pf ${TARGET_DIR}/usr/lib32 $BINARIES_DIR/initramfs/usr/

cp -Pf ${TARGET_DIR}/lib/* $BINARIES_DIR/initramfs/lib/ || true
cp -Prf ${TARGET_DIR}/dev/* $BINARIES_DIR/initramfs/dev/ || true

PUSHD=$(pwd)

cd $BINARIES_DIR/initramfs/usr/
ln -sf ../lib lib

cd $BINARIES_DIR/initramfs/bin
./busybox --list | xargs -I '{}' ln -fs busybox '{}'
cd $PUSHD

arm-urus-linux-gnueabihf-ldd --root ${TARGET_DIR} ${TARGET_DIR}/sbin/resize2fs | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -Hf ${TARGET_DIR}'{}'  $BINARIES_DIR/initramfs/lib/
arm-urus-linux-gnueabihf-ldd --root ${TARGET_DIR} ${TARGET_DIR}/usr/sbin/parted | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -Hf ${TARGET_DIR}'{}'  $BINARIES_DIR/initramfs/lib/
arm-urus-linux-gnueabihf-ldd --root ${TARGET_DIR} ${TARGET_DIR}/sbin/dosfsck | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -Hf ${TARGET_DIR}'{}'  $BINARIES_DIR/initramfs/lib/
arm-urus-linux-gnueabihf-ldd --root ${TARGET_DIR} ${TARGET_DIR}/sbin/e2fsck | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -Hf ${TARGET_DIR}'{}'  $BINARIES_DIR/initramfs/lib/
arm-urus-linux-gnueabihf-ldd --root ${TARGET_DIR} ${TARGET_DIR}/sbin/fsck | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -Hf ${TARGET_DIR}'{}'  $BINARIES_DIR/initramfs/lib/

rm -f $BINARIES_DIR/urus_srvmodefs.cpio.gz

cd $BINARIES_DIR/initramfs/
find . | cpio -o -H newc | gzip > $BINARIES_DIR/urus_srvmodefs.cpio.gz
cd $PUSHD
