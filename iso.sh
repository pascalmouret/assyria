#!/bin/sh
set -e
. ./build.sh

mkdir -p $BUILD_DIR/isodir/boot/grub
cp $BUILD_DIR/nimOS.bin $BUILD_DIR/isodir/boot/nimOS.bin
cp build/grub.cfg $BUILD_DIR/isodir/boot/grub/grub.cfg
grub-mkrescue -o $BUILD_DIR/nimOS.iso $BUILD_DIR/isodir

qemu-system-i386 -cdrom $BUILD_DIR/nimOS.iso
