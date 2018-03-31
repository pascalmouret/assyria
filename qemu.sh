#!/bin/sh
set -e
. ./build.sh

qemu-system-i386 -kernel $BUILD_DIR/nimOS.bin
