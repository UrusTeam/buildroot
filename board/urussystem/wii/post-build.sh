#!/bin/sh
# post-build.sh for Nintendo Wii
# 2018, Hiroshi Takey <htakey@gmail.com>

BOARD_DIR="$(dirname $0)"

URUSX_BIN=$BOARD_DIR/urusx
URUSX_BINTGT=${TARGET_DIR}/usr/bin/

cp -f $URUSX_BIN $URUSX_BINTGT

