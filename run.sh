export BUILD_ROOT=$(pwd)

make iso
qemu-system-i386 -cdrom target/assyria.iso
