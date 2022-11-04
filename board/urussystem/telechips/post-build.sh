#!/bin/sh
# post-build.sh for Telechips - Urus System.
# 2017,2022, Hiroshi Takey <htakey@gmail.com>

BOARD_DIR="$(dirname $0)"

MKBOOTIMG=$BOARD_DIR/tools/mkbootimg
BOOT_CMD=$BINARIES_DIR/Image
BOOT_CMD_H=$BINARIES_DIR/boot.img

if [ ! -f $MKBOOTIMG ]; then
    echo "Getting mkbootimg from sources..."
    #wget -P $BOARD_DIR/tools/ https://android.googlesource.com/platform/system/core/+archive/master/mkbootimg.tar.gz
    git clone https://github.com/osm0sis/Android-Image-Kitchen.git
    cd Android-Image-Kitchen
    git checkout AIK-Linux
    mkdir -p bin/linux/x86_64
    cd ..
    git clone https://github.com/osm0sis/mkbootimg.git tools
    cd tools
    make
    cp mkbootimg ../Android-Image-Kitchen/bin/linux/x86_64/
    cp unpackbootimg ../Android-Image-Kitchen/bin/linux/x86_64/
fi

URUS_INITSRC=$BOARD_DIR/S30psplash
URUS_INITTGT=${TARGET_DIR}/etc/init.d/

URUSX_BINSRC=$BOARD_DIR/urusx
URUSX_BINTGT=${TARGET_DIR}/usr/bin/

# Add a console on tty1
#if [ -e ${TARGET_DIR}/etc/inittab ]; then
#    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
#    sed -i '/GENERIC_SERIAL/a\
#ttyTCC0::respawn:/sbin/getty -L ttyTCC0 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
#fi

cp -f $BOARD_DIR/10-urus-app-sudoers ${TARGET_DIR}/etc/sudoers.d/
cp -f $BOARD_DIR/urus_weston.ini ${TARGET_DIR}/etc/

cp -f $BOARD_DIR/startapp.sh ${TARGET_DIR}/etc/profile.d/
cp -f $BOARD_DIR/urus_srvmode ${TARGET_DIR}/sbin/

cp -f $URUSX_BINSRC $URUSX_BINTGT
cp -f $URUS_INITSRC $URUS_INITTGT

DUMMY_RAMDISK=$BINARIES_DIR/dummyramdisk.cpio.gz

find system/skeleton | cpio --quiet -H newc -o | gzip -9 -n > $DUMMY_RAMDISK

# mkbootimg script
$MKBOOTIMG  --cmdline 'console=ttyTCC0,115200n8 root=/dev/mmcblk0p2 rw rootwait init=/linuxrc' \
            --kernel $BOOT_CMD --ramdisk $DUMMY_RAMDISK                                          \
            --pagesize 2048                                                                      \
            --base 0x80000000                                                                    \
            -o $BOOT_CMD_H

echo ok
