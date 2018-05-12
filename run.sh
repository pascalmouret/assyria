export BUILD_ROOT=$(pwd)
export ARCH_TARGET="i386"

make iso
qemu-system-i386 -cdrom target/assyria.iso -d cpu_reset -monitor stdio
