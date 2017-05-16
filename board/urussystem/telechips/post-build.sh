#!/bin/sh
# post-build.sh for Telechips - Urus System.
# 2017, Hiroshi Takey <htakey@gmail.com>

BOARD_DIR="$(dirname $0)"

MKBOOTIMG=$BOARD_DIR/tools/mkbootimg
BOOT_CMD=$BINARIES_DIR/Image
BOOT_CMD_H=$BINARIES_DIR/boot.img

if [ ! -f $MKBOOTIMG ]; then
    echo "Getting mkbootimg from sources..."
    wget -P $BOARD_DIR/tools/ https://android.googlesource.com/platform/system/core/+archive/master/mkbootimg.tar.gz
    tar -xvzf $BOARD_DIR/tools/mkbootimg.tar.gz -C $BOARD_DIR/tools/
fi

DUMMY_RAMDISK=$BINARIES_DIR/dummyramdisk.cpio.gz

find system/skeleton | cpio --quiet -H newc -o | gzip -9 -n > $DUMMY_RAMDISK

# mkbootimg script
$MKBOOTIMG  --cmdline 'console=ttyTCC0,115200n8 root=/dev/mmcblk0p2 rw rootwait init=/sbin/init' \
            --kernel $BOOT_CMD --ramdisk $DUMMY_RAMDISK                                          \
            --pagesize 2048                                                                      \
            --base 0x80000000                                                                    \
            -o $BOOT_CMD_H

echo ok
