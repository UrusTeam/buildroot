#!/bin/sh
# post-build.sh for Nexus 7
# 2018, Hiroshi Takey <htakey@gmail.com>

BOARD_DIR="$(dirname $0)"

URUS_INITANDROID=$BOARD_DIR/S02mountandroid
URUS_INITANDROIDTGT=${TARGET_DIR}/etc/init.d/

URUSX_BIN=$BOARD_DIR/urusx
URUSX_BINTGT=${TARGET_DIR}/usr/bin/

cp -f $URUSX_BIN $URUSX_BINTGT
cp -f $URUS_INITANDROID $URUS_INITANDROIDTGT

