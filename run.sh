./env.sh

make iso
qemu-system-i386 -cdrom target/assyria.iso -d cpu_reset -monitor stdio
