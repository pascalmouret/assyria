#!/bin/sh
export AS=$(pwd)/cross/bin/i586-elf-as
export GCC=$(pwd)/cross/bin/i586-elf-gcc
export NIM=nim

export TARGET='i386'
export BUILD_DIR=$(pwd)/target
export SYSROOT=$BUILD_DIR/sysroot

export PROJECTS='kernel'
