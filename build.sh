mkdir -p target
cross/bin/i686-elf-as src/boot.s -o target/boot.o
cross/bin/i686-elf-gcc -c src/kernel.c -o target/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
cross/bin/i686-elf-gcc -T src/linker.ld -o nimOS.bin -ffreestanding -O2 -nostdlib target/boot.o target/kernel.o -lgcc

mkdir -p isodir/boot/grub
cp nimOS.bin isodir/boot/nimOS.bin
cp grub.cfg isodir/boot/grub/grub.cfg
grub-mkrescue -o nimOS.iso isodir

rm -rf isodir